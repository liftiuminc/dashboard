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
        " WHERE tag_id IN (SELECT id FROM tags where publisher_id = ?)" +
        " AND " + model.new.time_column + " >= ? " +
        " AND " + model.new.time_column + " <= ? "
        
    stats = model.find_by_sql ["/*#1*/" + sql, current_user.publisher_id, @dates[0], @dates[1]]
    previous_stats = model.find_by_sql [sql, current_user.publisher_id, @dates[2], @dates[0]]
    @impressions = stats[0].loads.to_i
    @previous_impressions = previous_stats[0].loads.to_i

    sql = "SELECT SUM(revenue) AS revenue FROM revenues " +
        " WHERE tag_id IN (SELECT id FROM tags where publisher_id = ?)" +
        " AND day >= ? AND day <= ? "

    revenues = model.find_by_sql [sql, current_user.publisher_id, @dates[0], @dates[1]]
    previous_revenues = model.find_by_sql [sql, current_user.publisher_id, @dates[2], @dates[0]]
    @revenue = revenues[0].revenue.to_f
    @previous_revenue = previous_revenues[0].revenue.to_f

    @ecpm = Revenue.calculate_ecpm(@impressions, @revenue)
    @previous_ecpm = Revenue.calculate_ecpm(@previous_impressions, @previous_revenue)

   sql = "SELECT revenues.id, revenues.tag_id, " + 
	" COALESCE(SUM(attempts), 0) AS attempts," +
	" COALESCE(SUM(rejects), 0) AS rejects," + 
	" COALESCE(SUM(clicks), 0) AS clicks," +
	" COALESCE(SUM(revenue), 0) AS revenue, day from revenues" +
	" INNER JOIN tags on revenues.tag_id = tags.id" + 
	" AND tags.publisher_id = ?" + 
	" WHERE day >= ? AND day <= ?" + 
	" GROUP BY tags.network_id"
	" ORDER BY revenue DESC"

    @ad_network_revenues = Revenue.find_by_sql [sql, current_user.publisher_id, @dates[0], @dates[1]]

  end

end
