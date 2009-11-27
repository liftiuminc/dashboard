class RevenuesController < ApplicationController
  before_filter :require_admin 
  before_filter :find_enabled_networks
  before_filter :find_all_publishers

  def index
	@revenues = Revenue.revenues_table(params)
  end

  def index_results 
	@revenues = Revenue.revenues_table(params)
	render :partial => "results"
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
    @tag            = @revenue.tag
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
end
