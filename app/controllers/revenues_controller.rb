class RevenuesController < ApplicationController
  before_filter :require_admin 
  before_filter :find_enabled_networks
  before_filter :find_all_publishers
  before_filter :save_filter_fields, :only => [:index, :discrepancies]

  def index
	@revenues = Revenue.revenues_table(session[:data_entry_params] || params)
  end
  def index_results 
	@revenues = Revenue.revenues_table(session[:data_entry_params] || params)
	render :partial => "results"
  end 

  def discrepancies
	if !params["start_date"] 
	  params["start_date"] = 7.days.ago
	  @start_date = 7.days.ago
        end

	where = ""
        if params["publisher_id"] && params["publisher_id"].to_i > 0
          where += " AND tags.publisher_id = " + params["publisher_id"].to_i.to_s
        end

        if params["network_id"] && params["network_id"].to_i > 0
          where += " AND tags.network_id = " + params["network_id"].to_i.to_s
        end

	if params["start_date"] && !params["start_date"].blank?
	   where += " AND fills_day.day  >= '" + params["start_date"].to_time.to_s( :db ) + "'"
	end

	if params["end_date"] && !params["end_date"].blank?
	   where += " AND fills_day.day  <= '" + params["end_date"].to_time.to_s( :db ) + "'"
	end

	where += " GROUP BY tag_id ORDER BY diff DESC LIMIT 10;"

	commonjoin = " FROM revenues INNER JOIN fills_day ON fills_day.tag_id = revenues.tag_id AND revenues.day = fills_day.day" +
		" INNER JOIN tags on revenues.tag_id = tags.id"

	@revenues_pct_higher = Revenue.find_by_sql("SELECT revenues.*, SUM(revenues.attempts) AS network_loads," +
		" SUM(fills_day.loads) AS liftium_loads, ((sum(fills_day.loads) - sum(revenues.attempts)) / sum(fills_day.loads)) AS diff" +
		commonjoin + " WHERE revenues.attempts < fills_day.attempts " + where )

	@revenues_pct_lower = Revenue.find_by_sql("SELECT revenues.*, SUM(revenues.attempts) AS network_loads," +
		" SUM(fills_day.loads) AS liftium_loads, ((sum(revenues.attempts) - sum(fills_day.attempts)) / sum(revenues.attempts)) AS diff" +
		commonjoin + " WHERE revenues.attempts > fills_day.attempts " + where )

	@revenues_imp_higher = Revenue.find_by_sql("SELECT revenues.*, SUM(revenues.attempts) AS network_loads," +
		" SUM(fills_day.loads) AS liftium_loads, (sum(fills_day.loads) - sum(revenues.attempts)) AS diff" +
		commonjoin + " WHERE revenues.attempts < fills_day.attempts " + where ) 

	@revenues_imp_lower = Revenue.find_by_sql("SELECT revenues.*, SUM(revenues.attempts) AS network_loads," +
		" SUM(fills_day.loads) AS liftium_loads, (sum(revenues.attempts) - sum(fills_day.attempts)) AS diff" +
		commonjoin + " WHERE revenues.attempts > fills_day.attempts " + where ) 
  end

  def bulk_update 
      saved = 0

      revenues = params[:revenues]
      revenues.delete_if {|r| r["revenue"].blank? && r["attempts"].blank? }
      for rev in revenues do

	  if rev["id"].blank?
	    # Create new entry
	    @revenue  = Revenue.new(rev)
	    @revenue.user   = current_user
	    if @revenue.save
	       saved += 1
	    else
	       render :action => 'new' and return
	    end

	  else 
	    # Update existing entry
	    @revenue        = Revenue.find(rev["id"])
	    @revenue.attributes = rev
	    if @revenue.changed? 
	       @revenue.user   = current_user
	       if @revenue.save 
	         saved += 1
	       else
	         render :action => 'edit' and return
               end
	    end
	  end

      end
      flash[:notice] = "Saved " + saved.to_s + " entries."
      redirect_to revenues_url
  end

  def show
    @revenue = Revenue.find(params[:id])
  end
  
  ### use find_by_id so no exception is thrown
  def new
    @revenue = Revenue.new
    
    flash[:error] = "No tag found for #{params[:tag_id]}" unless @tag    
  end
  
  def create
    @revenue        = Revenue.new( params[:revenue] )
    @revenue.user   = current_user
 
    if @revenue.save
      flash[:notice] = "Successfully created revenue."
      redirect_to @revenue
    else
      render :action => 'new'
    end
  end
  
  def edit
    @revenue = Revenue.find(params[:id])
    @tag     = @revenue.tag
  end
  
  def update
    @revenue        = Revenue.find(params[:id])
    @revenue.user   = current_user    
    
    if @revenue.update_attributes(params[:revenue])
      flash[:notice] = "Successfully updated revenue."
      redirect_to @revenue
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    @revenue = Revenue.find(params[:id])
    @revenue.destroy
    flash[:notice] = "Successfully destroyed revenue."
    redirect_to revenues_url
  end

  def save_filter_fields
    if params.length > 2
      session[:data_entry_params] = params
      assign_filter_fields(params)
    else
      assign_filter_fields(session[:data_entry_params]) if session[:data_entry_params]
    end
  end

  def assign_filter_fields(params)
    @network_id = params[:network_id]
    @publisher_id = params[:publisher_id]
    @start_date = params[:start_date]
    @end_date = params[:end_date]
    @only_empty = params[:only_empty]
  end

end
