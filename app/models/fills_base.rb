class FillsBase < ActiveRecord::Base
  require "date_range_helper"

  belongs_to :tag

  def fill_rate 
    FillsBase.calculate_fill_rate(loads, attempts)
  end

  def slip
    attempts - (loads + rejects)
  end

  def self.calculate_fill_rate (loads, attempts)
    if (attempts.to_i.zero?)
	return 0.0
    end
    ((loads.to_f/attempts.to_f).to_f.round(3) * 100)
  end

  def time_name 
    time_column.capitalize
  end 
  
  def search_options (model, params)

    ### make the column name fully qualified, to avoid ambiguities
    ### with the revenue table (they both have a 'day' column for
    ### example) -Jos
    col = "#{model.table_name}.#{model.new.time_column}"

    ### the condition & the bind variables
    con = []
    var = []

    ### XXX FIXME this should probably be using sanitize_sql_hash_for_conditions

    ### dispatch table
    {   :enabled        => "enabled",
        :publisher_id   => "publisher_id",
        :network_id     => "network_id",
        :size           => "size",
        ### not used currently
        #:name_search    => "tag_name     like ?",
    }.each do |param, condition|
      if !params[param].blank?
        ### use 'in' so we can support groups as well
        args = params[param].class == 'Array' ? params[param] : [ params[param] ]
        
        ### XXX FIXME this feels way too cumbersome to be correct
        list = []
        args.each do |i|
          list.push( '?' )
        end
        
        con.push( condition + " IN(" + list.join( "," ) + ")" )
        var.push( *args )
      end
    end

    ### fix dates
    {   :start_date     => col + " >= ?",
        :end_date       => col + " <= ?"
    }.each do |param, condition|        
      if !params[param].to_s.blank?
        con.push( condition )
        var.push( params[param].to_time.to_s( :db ) )
      end        
    end


    ### Supply eCPM and CTR data at the daily interval
    ### Make sure to use a left outer join; the revenue for these days may not
    ### be filled in yet; a regular join would then not return results -jos
    ### XXX FIXME can't get the association to work. For now, we'll look this
    ### up from the view instead & code instead :(
#     if  model.table_name == "fills_day"
#       inc.push( :revenues )
#       con.push( 'fills_day.tag_id = revenues.tag_id' );
#       con.push( 'fills_day.day = revenues.day' )
#     end

    ### XXX FIXME can't get this association to work either. Using raw sql :(
#     inc.push( :tag )
#     con.push( 'fills_day.tag_id = tags.id' )

    ### done with includes/conditions
    options = {
        :conditions => [ con.join( " AND " ), *var ],
        :order      => col + " ASC",
        :joins      => [ "INNER JOIN tags ON " + model.table_name + ".tag_id = tags.id" ]
    }

    if (! params[:limit].to_s.empty?)
      options[:limit] = params[:limit].to_i

      if (! params[:offset].blank?)
        options[:offset] = params[:offset].to_i
      end
    end    
    
    return options
  end

  def search (model, params)
    options = self.search_options( model, params )    
    model.find( :all, options )
  end 
  
  def export_to_csv(fill_stats)

    if fill_stats[0].respond_to?("day")
	return export_to_csv_with_revenue(fill_stats)
    end
      
    require 'fastercsv'

    @outfile = "fills_" + time_name + "_" + Time.now.strftime("%m-%d-%Y") + ".csv"
    
    total_attempts = total_loads = total_rejects = total_slip = 0

    csv_data = FasterCSV.generate do |csv|
      csv << [
	"Publisher",
	"Ad Network",
	"Tag #",
	"Tag Name",
	"Size",
	time_name,
	"Attempts",
	"Loads",
	"Rejects",
	"Slip",
	"Fill Rate"
      ]
      fill_stats.each do |fill|
	csv << [
	fill.tag.publisher.site_name,
	fill.tag.network.network_name,
	fill.tag_id,
	fill.tag.tag_name,
	fill.tag.size,
	fill.time,
	fill.attempts,
	fill.loads,
	fill.rejects,
	fill.slip,
	fill.fill_rate.to_s + "%"
	]

	# Add up the totals
        total_attempts += fill.attempts
        total_loads += fill.loads
        total_rejects += fill.rejects
        total_slip += fill.slip
      end
      # Total line
      csv << [
	"Totals",
	"",
	"",
	"",
	"",
	"",
	total_attempts,
	total_loads,
	total_rejects,
	total_slip,
        FillsBase.calculate_fill_rate(total_loads, total_attempts).to_s + "%"
      ] 

    end
  end


  def export_to_csv_with_revenue(fill_stats)
    
    require 'fastercsv'

    @outfile = "fills_" + time_name + "_" + Time.now.strftime("%m-%d-%Y") + ".csv"
    
    total_attempts = total_loads = total_rejects = total_slip = total_clicks = 0
    total_revenue = total_ecpm = 0.00

    csv_data = FasterCSV.generate do |csv|
      csv << [
	"Publisher",
	"Ad Network",
	"Tag #",
	"Tag Name",
	"Size",
	time_name,
	"Attempts",
	"Loads",
	"Rejects",
	"Clicks",
	"Slip",
	"Fill Rate",
	"Revenue",
	"eCPM"
      ]
      fill_stats.each do |fill|
      
      ### this may be emptys
      rev = Revenue.find( :first, :conditions => {
                          :tag_id => fill.tag.id, :day => fill.day } )
      
	csv << [
	fill.tag.publisher.site_name,
	fill.tag.network.network_name,
	fill.tag_id,
	fill.tag.tag_name,
	fill.tag.size,
	fill.time,
	fill.attempts,
	fill.loads,
	fill.rejects,
	(rev ? rev.clicks : ''),
	fill.slip,
	fill.fill_rate.to_s + "%",
	( rev ? "$" + rev.revenue.to_f.round(2).to_s : '' ), 
	( rev ? "$" + rev.ecpm.to_f.round(2).to_s : '' ), 
	]

	# Add up the totals
        total_attempts += fill.attempts
        total_loads += fill.loads
        total_rejects += fill.rejects
        total_slip += fill.slip
        if rev
          total_clicks  += rev.clicks.to_i
          total_revenue += rev.revenue.to_f
          total_ecpm    += rev.ecpm.to_f
        end
      end

      # Total line
      if fill_stats.length > 0
	total_avg_ecpm = '$' + ((total_revenue/total_loads).round(2) * 1000).to_s
      else
	total_avg_ecpm = "-"
      end

      csv << [
	"Totals",
	"",
	"",
	"",
	"",
	"",
	total_attempts,
	total_loads,
	total_rejects,
	total_clicks,
	total_slip,
        FillsBase.calculate_fill_rate(total_loads, total_attempts).to_s + "%",
	'$' + total_revenue.to_f.round(2).to_s,
	total_avg_ecpm
      ] 

    end
  end
end
