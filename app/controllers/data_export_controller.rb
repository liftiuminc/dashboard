class DataExportController < ApplicationController
  before_filter :require_user
  before_filter :allowed_publishers
  before_filter :find_user_networks
  before_filter :find_user_adformats
  before_filter :set_limit

  ### setting this does not seem to work with a proc.. riddle me this ;(  
  def set_limit
    @limit = 250
  end

  def index
  end

  def create 

    ### if you're not an admin, you only get to see your own publisher
    if !current_user.admin?
      if current_publisher
        params[:publisher_id] = current_publisher.id
      else 
        require_admin
      end
    end      

    case params[:interval]
      when "day" 
        @model = FillsDay
      when "hour" 
        @model = FillsHour
      else 
        @model = FillsMinute
    end

    # Sanity checking on dates
    if !params[:date_select].blank? 
        dates = DateRangeHelper.get_date_range(params[:date_select])
        params[:start_date] = dates[0]
        params[:end_date]   = dates[1]
    end

    # radio buttons are annoying :(
    if !params[:only_enabled].blank? 
        params[:enabled] = 1 if params[:only_enabled].to_i > 0
    end        

    ### tables will be rotated, so we have a maximum amount of data in
    ### the tables at any given time. Make sure the dates requested 
    ### are held in the tables -Jos
    ### XXX FIXME This logic should probably be in the model.
    if !params[:start_date].blank?
      t = params[:start_date].to_time
      if params[:interval] != "day" && t + (31*86400) < Time.now 
        flash.now[:error] = "Please select 'Day' for interval for dates older than 30 days"
        render :index and return
      elsif params[:interval] == "minute" && t + (8*86400) < Time.now 
        flash.now[:error] = "Please select 'Hour' or 'Day' for interval for dates older than 7 days"
        render :index and return
      elsif !params[:end_date].blank? && t > params[:end_date].to_time
        flash.now[:error] = "Start Date must be before end date"
        render :index and return
      elsif !params[:end_date].blank? && params[:end_date].to_time > Time.now
        flash.now[:warning] = "Warning: End Date is in the future"
      end
    end

    ### we check for 'cvs' all over the place, make it a var
    is_csv = params[:format] == "csv" ? true : false

    ### maximum results in web view
    params[:limit] = @limit unless is_csv

    if params[:debug]
      flash[:notice] = "<span style='font-size:smaller'>SQL: " + @model.new.search(@model, params).inspect + "</span>"
    end

    @fill_stats = @model.new.search(@model, params)

    if @fill_stats.empty?
      if params[:format] == "csv"
        # FIXME: I shouldn't have to do this. render :index should work
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
