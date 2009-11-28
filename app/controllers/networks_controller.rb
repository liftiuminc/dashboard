class NetworksController < ApplicationController
  before_filter :require_admin

  def index
    @networks = Network.all(:order => "network_name");
  end
  
  def show
    @network = Network.find(params[:id])
  end

  def new
    @network = Network.new
    @network.network_tag_options.build
  end
  
  def create
    @network = Network.new(params[:network])
    if @network.save
      flash[:notice] = "Successfully created network."
      redirect_to @network
    else
      render :action => 'new'
    end
  end
  
  def edit
    @network = Network.find(params[:id])
  end
  
  def update
    @network = Network.find(params[:id])
    if @network.update_attributes(params[:network])
      flash[:notice] = "Successfully updated network."
      redirect_to networks_url
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    @network = Network.find(params[:id])
    @network.destroy
    flash[:notice] = "Successfully destroyed network."
    redirect_to networks_url
  end

  def ad_preview
    @network    = Network.find(params[:id])    
    @title      = "Network - " + @network.network_name
    @tags       = Tag.find( :all, :conditions => {
                                :network_id => @network.id,
                                :enabled    => true
                            })    
  end

  def dropdown 
    if current_user.admin? && params[:publisher_id] && !params[:publisher_id].blank?
      @networks = Network.find_by_sql(["SELECT networks.* from networks WHERE enabled = ? AND id IN (SELECT DISTINCT network_id from tags where publisher_id = ?) ORDER BY network_name", 1, params[:publisher_id]])
    else 
      @networks = Network.find(:all, :conditions => {:enabled => 1}, :order => "network_name")
    end
    render :partial => "dropdown"    
  end

end
