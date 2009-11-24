class RevenuesController < ApplicationController
  before_filter :require_admin 
  before_filter :find_enabled_networks
  before_filter :find_all_publishers


  def index
    conditions = {}
    
    if params[:commit] 

        if !params[:network_id].blank?
            conditions[ :network_id ] = params[:network_id]
        elsif !params[:publisher_id].blank?
            conditions[ :publisher_id ] = params[:publisher_id]      
        end

        ### @day is used in the template to load the associated revenue
        @day  = params[:day].to_date.to_s
        @tags = Tag.new.search( conditions )
        
        unless @tags.length > 0 
            flash.now[:warning] = "No tags found for these criteria -- were the tags enabled at this date?"
        end            
    end    
  end
  
  def show
    @revenue = Revenue.find(params[:id])
    @tag     = @revenue.tag
  end
  
  ### use find_by_id so no exception is thrown
  def new
    @revenue = Revenue.new
    @tag     = Tag.find_by_id( params[:tag_id] )
    
    flash[:error] = "No tag found for #{params[:tag_id]}" unless @tag    
  end
  
  def create
    @revenue        = Revenue.new( params[:revenue] )
    @tag            = @revenue.tag
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
