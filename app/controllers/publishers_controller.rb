class PublishersController < ApplicationController
  before_filter :require_user, :except => [ :terms_and_conditions ]
  before_filter :require_admin, :only => [ :index, :create, :new, :edit ]
  before_filter :allowed_publishers, :only => [:ad_preview, :ad_formats, :quality_control, :site_info]

  def index
    @publishers = Publisher.all(:order => :site_name)
  end
  
  def show
    id = !current_user.is_admin? ? current_publisher.id : params[:id]
    @publisher = Publisher.find( id )
  end

  def new
    @publisher = Publisher.new
  end
  
  def create
    @publisher = Publisher.new(params[:publisher])
    if @publisher.save
    
      ### any associated notes? See FB 24
      if params[:note]
        comment = Comment.new( :title   => params[:publisher][:site_name],
                               :comment => params[:note][:publisher] )

        @publisher.add_comment comment
      end
      
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
    if current_user.is_admin? && params[:publisher_id] 
      @publisher = Publisher.find(params[:publisher_id])
    elsif current_user.is_admin? && params[:id] 
      @publisher = Publisher.find(params[:id])
    else 
      @publisher = current_user.publisher
    end
    if @publisher.update_attributes(params[:publisher])
    
      ### any associated notes? See FB 24
      if params[:note]

        ### if we already have a comment, update it
        if !@publisher.comments.empty?
          @publisher.comments[0].update_attributes( 
                    :comment => params[:note][:publisher] )

        ### otherwise, create a new one
        else
          comment = Comment.new( :title   => params[:publisher][:site_name],
                                 :comment => params[:note][:publisher] )

          @publisher.add_comment comment
        end
      end    
    
      flash[:notice] = "Successfully updated publisher settings"
      if params[:redirect_back]
        redirect_to :back
      else 
        redirect_to publishers_url
      end
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
    id          = !current_user.is_admin? ? current_publisher.id : params[:id]
    @publisher  = Publisher.find( id )
    @title      = "Publisher - " + @publisher.site_name
    
    @tags       = Tag.find( :all, :conditions => { 
                                :publisher_id   => @publisher.id,
                                :enabled        => true
                            })
  end

  def ad_formats 
    @ad_formats = AdFormat.all(:order => "id")
    if current_user.is_admin? && params[:publisher_id] 
      @publisher = Publisher.find(params[:publisher_id])
    elsif current_user.publisher
      @publisher = current_user.publisher
    else 
      @publisher = Publisher.first :order => "site_name"
    end
  end

  def save_ad_formats
    if current_user.is_admin? && params[:publisher_id] 
      @publisher = Publisher.find(params[:publisher_id])
    else 
      @publisher = current_user.publisher
    end
    
    params[:publisher] ||= {}
    params[:publisher]["ad_format_ids"] ||= []
    if @publisher.update_attributes(params[:publisher])
      flash[:notice] = "Successfully updated ad formats."
      redirect_to :action => 'ad_formats'
    else
      render :action => 'ad_formats'
    end
  end

  def quality_control 
    if current_user.is_admin? && params[:publisher_id] 
      @publisher = Publisher.find(params[:publisher_id])
    elsif current_user.publisher
      @publisher = current_user.publisher
    else 
      @publisher = Publisher.first :order => "site_name"
    end
    @networks = Network.find_by_sql(["SELECT * FROM networks WHERE id IN
		(SELECT DISTINCT network_id from tags where tags.publisher_id = ? )
		ORDER BY brand_safety_level DESC", @publisher.id])
  end

  def site_info 
    if current_user.is_admin? && params[:publisher_id] 
      @publisher = Publisher.find(params[:publisher_id])
    elsif current_user.publisher
      @publisher = current_user.publisher
    else 
      @publisher = Publisher.first :order => "site_name"
    end
  end

  def terms_and_conditions 
    if params[:nolayout]
	render :layout => false
    end
  end

end
