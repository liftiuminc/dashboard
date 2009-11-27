class RevenuesController < ApplicationController
  before_filter :require_admin 
  before_filter :find_enabled_networks
  before_filter :find_all_publishers
  before_filter :save_filter_fields, :only => [:index]

  def index
	@revenues = Revenue.revenues_table(params)
  end

  def index_results 
	@revenues = Revenue.revenues_table(params)
	render :partial => "results"
  end 

  def bulk_update 
      saved = 0

      revenues = params[:revenues]
      revenues.delete_if {|r| r["revenue"].blank? || r["attempts"].blank? }
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
