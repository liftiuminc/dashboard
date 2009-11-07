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
        permission_denied("Your account is not associated with a publisher")
        return
    end
        
    params[:date_select] ||= "Last 7 Days"

    @dates = DateRangeHelper.get_date_range(params[:date_select])
    
    
    if @dates[0].to_time < (DateTime.now - 7.days)
        model = FillsDay
    else
        model = FillsMinute
    end
    
    # FIXME move to model once Jos' is done refactoring
    # REALLYFIXME. What a mess.
    sql = "SELECT * FROM " + model.table_name +
        " WHERE tag_id IN (SELECT id FROM tags where publisher_id = ?)" +
        " AND " + model.new.time_column + " >= ? " +
        " AND " + model.new.time_column + " <= ? " +
	" ORDER by " + model.new.time_column 
        
    @stats = model.find_by_sql [sql, current_user.publisher_id, @dates[0], @dates[1]]
    @previous_stats = model.find_by_sql [sql, current_user.publisher_id, @dates[2], @dates[0]]
    @impressions = @stats.sum(&:loads)
    @previous_impressions = @previous_stats.sum(&:loads)

    @impressions_graph_data = []
    for stat in @stats do
      @impressions_graph_data.push([stat.time.to_date.strftime("%m/%d"), stat.loads])
    end

    sql = "SELECT id, day, " +
	" COALESCE(SUM(attempts), 0) AS attempts," +
        " COALESCE(SUM(rejects), 0) AS rejects," +
        " COALESCE(SUM(clicks), 0) AS clicks," +
        " COALESCE(SUM(revenue), 0) AS revenue  FROM revenues " +
        " WHERE tag_id IN (SELECT id FROM tags where publisher_id = ?)" +
        " AND day >= ? AND day <= ? GROUP BY day"

    @revenues = model.find_by_sql [sql, current_user.publisher_id, @dates[0], @dates[1]]
    @previous_revenues = model.find_by_sql [sql, current_user.publisher_id, @dates[2], @dates[0]]
  
    @revenue = @revenues.sum(&:revenue).to_f
    @previous_revenue = @revenues.sum(&:revenue).to_f

    @revenue_graph_data = [] 
    @ecpm_graph_data = []
    for rev in @revenues do
      @revenue_graph_data.push([rev.day.to_date.strftime("%m/%d"), rev.revenue.to_f.round(2)])
      @ecpm_graph_data.push([rev.day.to_date.strftime("%m/%d"), Revenue.calculate_ecpm(rev.attempts, rev.revenue)])
    end

    @ecpm = Revenue.calculate_ecpm(@impressions, @revenue)
    @previous_ecpm = Revenue.calculate_ecpm(@previous_impressions, @previous_revenue)


    sql = "SELECT revenues.id, revenues.tag_id, tags.size, " + 
	" COALESCE(SUM(attempts), 0) AS attempts," +
	" COALESCE(SUM(rejects), 0) AS rejects," + 
	" COALESCE(SUM(clicks), 0) AS clicks," +
	" COALESCE(SUM(revenue), 0) AS revenue, day, MAX(day) AS max_day FROM revenues" +
	" INNER JOIN tags on revenues.tag_id = tags.id" + 
	" AND tags.publisher_id = ?" + 
	" WHERE day >= ? AND day <= ?" + 
	" GROUP BY ?"
	" ORDER BY revenue DESC"
    @ad_network_revenues = Revenue.find_by_sql [sql, current_user.publisher_id, @dates[0], @dates[1], "tags.network_id"]

    @ad_size_revenues = Revenue.find_by_sql [sql, current_user.publisher_id, @dates[0], @dates[1], "tags.size"]

  end

end
