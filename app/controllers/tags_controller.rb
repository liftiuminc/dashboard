class TagsController < ApplicationController
  before_filter :require_user
  before_filter :require_power_user, :except => [:index, :generator, :html_preview]
  before_filter :require_admin,      :only => [:destroy]
  before_filter :save_filter_fields, :only => [:index]
  before_filter :debug_sql,          :only => [:index]
  before_filter :find_user_networks, :only => [:select_network, :new, :edit, :copy, :index]
  before_filter :allowed_publishers
  before_filter :find_user_adformats,:only => [:new, :edit, :copy, :index, :generator]

  def index
    conditions = session[:tag_params] || {}

    ### arbitrary 50 record limit in the model code
    conditions[:limit] = 250
  
    ### you can only find things for YOUR publisher
    if !current_user.is_admin?
        conditions[:publisher_id] = current_publisher.id
    end
    
    @countries  = TagTarget.new.all_countries
    @tags       = Tag.new.search( conditions )

    ### should we limit the output by country? See FB 153
    ### Logic somewhat complicated by a non-normalized DB
    if !params[:country].blank?
      filtered_tags = []
      @tags.map do |t|
        tt = TagTarget.find( :first, :conditions => [
                            "tag_id = ? and key_name = ? and key_value like ?",
                            t.id, 'country', "%#{params[:country]}%" ] )
        
        filtered_tags.push t if tt
      end
      @tags = filtered_tags
    end

    flash[:warning] = "No matching tags found" if @tags.empty?
  end

  def bulk_update
      saved = 0

      tags = params[:tags]
      for tag in tags do

	# Update existing entry
	@tag        = Tag.find(tag["id"])
	@tag.attributes = tag
	if @tag.changed?
	   if @tag.save
	     saved += 1
	   else
	     render :action => 'edit' and return
	   end
	end

      end
      flash[:notice] = "Updated " + saved.to_s + " tags."
      redirect_to tags_url
  end


  def show
    @tag = Tag.find(params[:id])
    @networks
  end

  def select_network
    @tag        = Tag.new
    @networks   = find_enabled_networks
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
    iframe_with_always_fill_xdm_iframe_path(@tag)

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
    iframe_with_always_fill_xdm_iframe_path(@tag)
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
      if !current_user.is_admin? 
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

  # Fogbugz 86
  def iframe_with_always_fill_xdm_iframe_path(tag)
    if !tag.network or !tag.publisher
      # This will already fail for other reasons
      return
    elsif (tag.tag =~ /iframe/i or (tag.tag.empty? and tag.network.tag_template =~ /iframe/i)) and tag.publisher.xdm_iframe_path.blank? and !tag.always_fill
      flash[:warning] = "Since the publisher's 'cross domain iframe path' is not set, this tag will not fill for HTML 4 browsers (IE 6/7)"
    end
  end

end
