class HomesController < ApplicationController
  before_filter :require_user, :only => ["publisher", "admin"]
  before_filter :require_admin, :only => ["admin"]

  def index
    if current_user 
      if current_user.publisher
        redirect_to url_for(:action => "publisher") and return
      elsif current_user.admin 
        redirect_to url_for(:action => "admin") and return
      end
    end
    # not logged in, render home
  end

  def admin
  end

  def publisher
    if !current_user.publisher
	permission_denied
	return
    end
	
    params[:date_select] ||= "Yesterday"

    @dates = DateRangeHelper.get_date_range(params[:date_select])
    @dates[1] ||= DateTime.now

    if @dates[0].to_time < (DateTime.now - 7.days)
	model = FillsDay
    else
	model = FillsMinute
    end
    
    # FIXME move to model once Jos' is done refactoring
    sql = "SELECT SUM(loads) AS loads FROM " + model.table_name +
	" WHERE tag_id IN (SELECT tag_id FROM tags where publisher_id = ?)" +
	" AND " + model.new.time_column + " >= ? " +
	" AND " + model.new.time_column + " <= ? "
	
    stats = model.find_by_sql [sql, current_user.publisher_id, @dates[0], @dates[1]]
    previous_stats = model.find_by_sql [sql, current_user.publisher_id, @dates[2], @dates[1]]
    @impressions = stats[0].loads.to_i
    @previous_impressions = previous_stats[0].loads.to_i

    sql = "SELECT SUM(revenue) AS revenue FROM revenues " +
	" WHERE tag_id IN (SELECT tag_id FROM tags where publisher_id = ?)" +
	" AND day >= ? AND day <= ? "

    revenues = model.find_by_sql [sql, current_user.publisher_id, @dates[0], @dates[1]]
    previous_revenues = model.find_by_sql [sql, current_user.publisher_id, @dates[2], @dates[1]]
    @revenue = revenues[0].revenue.to_f
    @previous_revenue = previous_revenues[0].revenue.to_f

    @ecpm = Revenue.calculate_ecpm(@impressions, @revenue)
    @previous_ecpm = Revenue.calculate_ecpm(@previous_impressions, @previous_revenue)

  end

end
