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
    if current_user.admin? 
        if params[:publisher_id]
	  @publisher = Publisher.find(params[:publisher_id])
        else 
	  @publisher = Publisher.first;
        end
    else 
	@publisher = current_user.publisher
    end
        
    params[:date_select] ||= "Last 7 Days"

    @dates = DateRangeHelper.get_date_range(params[:date_select])
    
    if @dates[0].to_time > (DateTime.now - 1.hour)
        model = FillsMinute
	time_format = "%I:%M:p"
    elsif @dates[0].to_time > (DateTime.now - 7.days)
        model = FillsHour
	time_format = "%I:%p"
    else
        model = FillsDay
	time_format = "%m/%d"
    end

    
    # FIXME move to model once Jos' is done refactoring
    # REALLYFIXME. What a mess.
    col = model.new.time_column
    sql = "SELECT * FROM #{model.table_name}"+
        " WHERE tag_id IN (SELECT id FROM tags where publisher_id = ?)" +
        " AND #{col} >= ?  AND #{col} <= ? GROUP BY #{col} ORDER by #{col} DESC"
        
    @stats = model.find_by_sql [sql, @publisher.id, @dates[0], @dates[1]]
    @previous_stats = model.find_by_sql [sql, @publisher.id, @dates[2], @dates[0]]
    @impressions = @stats.sum(&:loads)
    @previous_impressions = @previous_stats.sum(&:loads)



    @impressions_graph_data = []
    for stat in @stats do
      @impressions_graph_data.push([stat.time.to_time.strftime(time_format), stat.loads])
      # TODO smarter sampling
      if @impressions_graph_data.length > 25
	break
      end
    end
    @impressions_graph_data.reverse!

    sql = "SELECT tags.network_id, COALESCE(SUM(loads), 0) AS loads, tag_id FROM #{model.table_name}"+
	" INNER JOIN tags on #{model.table_name}.tag_id = tags.id " +
        " WHERE tag_id IN (SELECT id FROM tags where publisher_id = ?)" +
        " AND #{col} >= ?  AND #{col} <= ? GROUP BY tags.network_id ORDER BY loads"

    @stats_by_network = model.find_by_sql [sql, @publisher.id, @dates[0], @dates[1]]
    @total_loads = @stats_by_network.sum(&:loads).to_f
    @network_graph_data = [] 
    other = 0
    for s in @stats_by_network do 
	if (s.loads.to_f / @total_loads) < 0.02
	   other += s.loads
	else 
           @network_graph_data.push([s.tag.network.network_name, s.loads])
	end
    end
    if other > 0
	@network_graph_data.push(["Other", other])
    end


    sql = "SELECT id, day, " +
	" COALESCE(SUM(attempts), 0) AS attempts," +
        " COALESCE(SUM(rejects), 0) AS rejects," +
        " COALESCE(SUM(clicks), 0) AS clicks," +
        " COALESCE(SUM(revenue), 0) AS revenue  FROM revenues " +
        " WHERE tag_id IN (SELECT id FROM tags where publisher_id = ?)" +
        " AND day >= ? AND day <= ? GROUP BY day ORDER BY day"

    @revenues = model.find_by_sql [sql, @publisher.id, @dates[0], @dates[1]]
    @previous_revenues = model.find_by_sql [sql, @publisher.id, @dates[2], @dates[0]]
  
    @revenue = @revenues.sum(&:revenue).to_f
    @previous_revenue = @revenues.sum(&:revenue).to_f

    @revenue_graph_data = [] 
    @ecpm_graph_data = []
    for rev in @revenues do
      @revenue_graph_data.push([rev.day.to_date.strftime("%m/%d"), rev.revenue.to_f.round(2)])
      @ecpm_graph_data.push([rev.day.to_date.strftime("%m/%d"), Revenue.calculate_ecpm(rev.attempts, rev.revenue).round(3)])
      # TODO smarter sampling
      if @revenue_graph_data.length > 25
	break
      end
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

    @ad_network_revenues = Revenue.find_by_sql [sql, @publisher.id, @dates[0], @dates[1], "tags.network_id"]

    @ad_size_revenues = Revenue.find_by_sql [sql, @publisher.id, @dates[0], @dates[1], "tags.size"]

  end

end
