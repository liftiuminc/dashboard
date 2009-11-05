class TagsController < ApplicationController
  before_filter :require_user
  before_filter :require_admin,      :except => [:index, :generator, :html_preview]
  before_filter :save_filter_fields, :only => [:index]
  before_filter :debug_sql,          :only => [:index]
  before_filter :find_user_networks, :only => [:select_network, :new, :edit, :copy, :index]
  before_filter :allowed_publishers
  before_filter :find_user_adformats,:only => [:new, :edit, :copy, :index, :generator]

  def index
    conditions = session[:tag_params] || {}
  
    ### you can only find things for YOUR publisher
    if !current_user.admin?
        conditions[:publisher_id] = current_publisher.id
    end
    
    @tags = Tag.new.search( conditions )
    flash[:warning] = "No matching tags found" if @tags.empty?
  end

  def show
    @tag = Tag.find(params[:id])
  end

  def select_network
    @tag = Tag.new
  end

  def new
    if !params[:network_id]
      flash[:notice] = "Please select a network to continue"
      redirect_to :action => 'select_network'
    else
      @tag = Tag.new
      @tag.network_id = params[:network_id]
      @tag.tag_options.build
      @tag.always_fill = @tag.network.default_always_fill

    end
  end

  def create
    @tag = Tag.new(params[:tag])

    if @tag.save

      ### any associated notes? See FB 24
      if params[:note]
        comment = Comment.new( :title => params[:tag][:tag_name],
                               :comment => params[:note][:tag] )

        @tag.add_comment comment
      end

      ### is the network US only? then set the tag_target as well. See FB 36
      if @tag.network.us_only?
        tt = TagTarget.new( :key_name => 'country', :key_value => 'us' );
        @tag.update_attributes( :tag_targets => [tt] )
      end

      flash[:notice] = "Successfully created tag."
      redirect_to @tag
    else
      render :action => 'new'
    end
  end

  def edit
    @tag = Tag.find(params[:id])
  end

  def copy
    @tag_orig = Tag.find(params[:id])
    @tag = @tag_orig.clone

    ### add the date to the name, as names are unique and an error will
    ### occur on the 2nd copy otherwise
    @tag.tag_name = "Copy of #{@tag.tag_name} made at " + DateTime.now.to_s

    ### clone the options
    options = @tag_orig.tag_options.map { |to|
      c = to.clone
      c.tag_id = @tag.id
      c
    }
    @tag.update_attributes( :tag_options => options )

    ### clone the targets
    targets = @tag_orig.tag_targets.map { |tt|
      c = tt.clone
      c.tag_id = @tag.id
      c
    }
    @tag.update_attributes( :tag_targets => targets );

    render :action => 'edit'
  end

  def update
    @tag = Tag.find(params[:id])
    if @tag.update_attributes(params[:tag])

      ### any associated notes? See FB 24
      if params[:note]

        ### if we already have a comment, update it
        if !@tag.comments.empty?
          @tag.comments[0].update_attributes( :comment => params[:note][:tag] )

          ### otherwise, create a new one
        else
          comment = Comment.new( :title => params[:tag][:tag_name],
                                 :comment => params[:note][:tag] )

          @tag.add_comment comment
        end
      end

      flash[:notice] = "Successfully updated tag."
      redirect_to tags_url
    else
      render :action => 'edit'
    end
  end

  def toggle
    @tag    = Tag.find( params[:id] )
    diag    = (@tag.enabled = !@tag.enabled) ? "enabled" : "disabled"

    if @tag.save
      flash[:notice] = "Successfully #{diag} tag #{@tag.tag_name}"
    else
      flash[:error] = "Failed to #{diag} tag #{@tag.tag_name}"
    end

    redirect_to tags_url

  end

  def destroy
    @tag = Tag.find(params[:id])
    @tag.destroy
    flash[:notice] = "Successfully destroyed tag."
    redirect_to tags_url
  end

  def generator
    @tag = Tag.new
  end

  def html_preview
    if params[:id]

      ### you can only view your own tags
      conditions = {}
      if !current_user.admin? 
        conditions[:publisher_id] = current_publisher.id
      end  
    
      @tag = Tag.find( params[:id], :conditions => conditions )
      render :action => :html_preview, :layout => "bare"
    elsif params[:html]
      @tag = Tag.new
      @tag.tag = params[:html]
      render :action => :html_preview, :layout => "bare"
    else
      flash[:error] = "html_preview expects either html or id"
      redirect_to @tag
    end
  end

  private
  def debug_sql
    flash[:notice] = "<span style='font-size:smaller'>SQL: #{Tag.new.search_sql(params).inspect}</span>" if params[:debug]
  end

  def save_filter_fields
    if params.length > 2
      session[:tag_params] = params
      assign_filter_fields(params)
    else
      assign_filter_fields(session[:tag_params]) if session[:tag_params]
    end
  end

  def assign_filter_fields(params)
    @network_id = params[:network_id]
    @publisher_id = params[:publisher_id]
    @size = params[:size]
    @name_search = params[:name_search]
    @include_disabled = params[:include_disabled]
  end
end
