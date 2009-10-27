class DataExportController < ApplicationController
  before_filter :require_user

  def index
    setup_vars
  end

  def setup_vars 
    if ! current_user.publisher_id 
	@publishers = Publisher.all(:order => "site_name")
        @networks = Network.all(:conditions => ["enabled = ?", 1], :order => "network_name")
        @adformats = AdFormat.all
    else 
	# FIXME, there is probably a more ActiveRecordy way to handle this 
        @networks = Network.find_by_sql(["SELECT * FROM networks WHERE id IN (SELECT network_id FROM tags where publisher_id = ? AND enabled = ?)", current_user.publisher_id, 1])
        @adformats = AdFormat.find_by_sql(["SELECT * FROM ad_formats WHERE size IN (SELECT size FROM tags where publisher_id = ? AND enabled = ?)", current_user.publisher_id, 1])
    end
    @limit = 250
  end

  def create 
    setup_vars

    if current_user.publisher_id
       params[:publisher_id] = current_user.publisher_id
    elsif !current_user.admin?
       # Belt & Suspenders, just to make sure we don't give out everyone's data
       permission_denied "Your account is not an administrator and it is not associated with a publisher";
       return false
    end

    case params[:interval]
      when "day" 
        @model = FillsDay
        @time_name = "Day"
      when "hour" 
        @model = FillsHour
        @time_name = "Hour"
      else 
        @model = FillsMinute
        @time_name = "Minute"
    end

    params[:start_date1] = params[:start_date]
    # Sanity checking on dates
    if !params[:date_select].blank? 
	dates = @model.new.get_date_range(params[:date_select])
        params[:start_date] = dates[0]
        params[:end_date] = dates[1]
    end
    params[:start_date2] = params[:start_date]

    if !params[:start_date].blank?
      s = params[:start_date].to_time
      if params[:interval] != "day" && s + (31*86400) < Time.now 
	flash.now[:error] = "Please select 'Day' for interval for dates older than 30 days"
        render :index and return
      elsif params[:interval] == "minute" && s + (8*86400) < Time.now 
	flash.now[:error] = "Please select 'Hour' or 'Day' for interval for dates older than 7 days"
        render :index and return
      elsif !params[:end_date].blank? && s > params[:end_date].to_time
	flash.now[:error] = "Start Date must be before end date"
        render :index and return
      elsif !params[:end_date].blank? && params[:end_date].to_time > Time.now
	flash.now[:warning] = "Warning: End Date is in the future"
      end
    end

    if params[:format] != "csv"
      params[:limit] = @limit
    end

    if params[:debug]
      flash[:notice] = "<span style='font-size:smaller'>SQL: " + @model.new.search_sql(@model, params).inspect + "</span>"
    end

    @fill_stats = @model.new.search(@model, params)

    if @fill_stats.empty?
      if params[:format] == "csv"
	# I shouldn't have to do this. render :index should work
        render :text => "No stats for CSV, please try again"
      else
        flash.now[:warning] = "No matching stats"
      end
      return
    elsif @fill_stats.length == @limit
      flash[:warning] = "Limit of #{@limit} reached. Use the CSV option to see all"
    end 

    if params[:format] == "csv"
      send_data @model.new.export_to_csv(@fill_stats),
        :type => 'text/csv; header=present',
        :disposition => "attachment; filename=liftium_data_export.csv" 
      return
    end
  end

end
