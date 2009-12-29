class MoversController < ApplicationController
  before_filter :require_admin

#require 'pp'

  def index
    @limit     = 10
    @timeframe = !params[:date_select].blank? ? params[:date_select] : "Last Hour"  
    dates      = DateRangeHelper.get_date_range( @timeframe )
  
    ### FIXME duplicates from homes controller -- can't we have a 'give me the
    ### right model' function in fillsbase? I've tried adding it but rails gets
    ### confused since FillsBase doesn't have an associated table, but it DOES
    ### inherit from activerecord -Jos
    if dates[0].to_time < (DateTime.now - 7.days)
        model = FillsDay
    else
        model = FillsMinute
    end
    

    @stats = {}

    ### calculations have to be done in the application space, as we can't
    ### select the fill rate from mysql -Jos
    col = model.new.time_column
    
    { :cur => [ dates[0], dates[1] ], 
      :old => [ dates[2], dates[0] ] 
    }.each do |key, list|
    
      @stats[ key ] = {}
        
      list = model.find(
        :all,
        :select     => "SUM(attempts) as attempts, SUM(loads) as loads, tag_id",
        :group      => :tag_id,
        :conditions => [ 
          "#{col} >= :start_date and #{col} <= :end_date",
          {   :start_date => list[0], 
              :end_date   => list[1],
          } 
        ]
      )

      ### to be able to do lookups, we have to key these by tag_id, so
      ### convert. we'll compute the fillrate at the same time.
      ### Since we can't assign to activerecords, we'll convert to a hash
      ### as well.
      ### this math has to be done on FLOATS, or ruby will happily return 0
      list.each do |e|
        h                       = e.attributes_before_type_cast
        h[:fill]                = ( e.loads.to_f * 100.to_f / e.attempts.to_f )

        ### limit it to active tags
        @stats[key][ e.tag_id ] = h if e.attempts > 100
      end
      
    end

#pp @stats

    ### now find out which tags did the best/worst
    @results = { }

    ### find top/bottom attempts
    ### string and symbols are NOT interoperable
    ### the data for the previous daterange may not be available, so guard for that
    @results[:attempts] = @stats[:cur].sort_by { |h|
                            if !@stats[:old].blank? and !@stats[:old][ h[0] ].blank?
                              n = h[1]["attempts"].to_f
                              o = @stats[:old][ h[0] ]["attempts"].to_f
                              h[1][:attempts_delta] = (sprintf "%.2f", ((n-o)/o)*100).to_f
                            else
                              h[1][:attempts_delta] = 0.to_f
                            end    
                          }    

    @results[:fill] = @stats[:cur].sort_by { |h|
                            if !@stats[:old].blank? and !@stats[:old][ h[0] ].blank?
                              n = h[1][:fill].to_f
                              o = @stats[:old][ h[0] ][:fill].to_f
                              h[1][:fill_delta] = (sprintf "%.2f", ((n-o)/o)*100).to_f
                            else 
                              h[1][:fill_delta] = 0.to_f
                            end  
                          }    

#pp @results

    ### the top & bottom list for each. Due to the sort, the lowest ones are
    ### sorted at the front, so the bottom ones are the FIRST x, the top ones
    ### are the LAST x. Make sure the last ones are reversed!
    @top_bottom = {
      :fill_top         => @results[:fill].last( @limit ).reverse,  
      :fill_bottom      => @results[:fill].first( @limit ),    
      :attempts_top     => @results[:attempts].last( @limit ).reverse,    
      :attempts_bottom  => @results[:attempts].first( @limit ),    
    }

#pp @top_bottom

  end
end
