class PublishersController < ApplicationController
  before_filter :require_user
  before_filter :require_admin, :except => [:show, :ad_preview, :ad_formats]
  before_filter :allowed_publishers, :only => [:ad_preview, :ad_formats]

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

  def ad_formats 
    @ad_formats = AdFormat.all(:order => "id")
    if current_user.admin? && params[:id] 
      @publisher = Publisher.find(params[:id])
    elsif current_user.publisher
      @publisher = current_user.publisher
    else 
      @publisher = Publisher.first :order => "site_name"
    end
  end

  def save_ad_formats
    params[:publisher][:ad_format_ids] ||= []
    @publisher = Publisher.find(params[:id])
    if @publisher.update_attributes(params[:publisher])
      flash[:notice] = "Successfully updated sizes."
      redirect_to :action => 'ad_formats'
    else
      render :action => 'ad_formats'
    end
  end
end
