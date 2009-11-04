class PublishersController < ApplicationController
  before_filter :require_user
  before_filter :require_admin, :except => [:show]

  def index
    @publishers = Publisher.all
  end
  
  def show
    id = !current_user.admin? ? current_publisher.id : params[:id]
    @publisher = Publisher.find( id )
  end
  
  def new
    @publisher = Publisher.new
  end
  
  def create
    @publisher = Publisher.new(params[:publisher])
    if @publisher.save
      flash[:notice] = "Successfully created publisher."
      redirect_to @publisher
    else
      render :action => 'new'
    end
  end
  
  def edit
    @publisher = Publisher.find(params[:id])
  end
  
  def update
    @publisher = Publisher.find(params[:id])
    if @publisher.update_attributes(params[:publisher])
      flash[:notice] = "Successfully updated publisher."
      redirect_to publishers_url
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    @publisher = Publisher.find(params[:id])
    @publisher.destroy
    flash[:notice] = "Successfully destroyed publisher."
    redirect_to publishers_url
  end
  
  def ad_preview
    id          = !current_user.admin? ? current_publisher.id : params[:id]
    @publisher  = Publisher.find( id )
    @title      = "Publisher - " + @publisher.site_name
    
    @tags       = Tag.find( :all, :conditions => { 
                                :publisher_id   => @publisher.id,
                                :enabled        => true
                            })
  end
  
end
