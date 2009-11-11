class PublisherNetworkLoginsController < ApplicationController
  before_filter :require_user
  before_filter :allowed_publishers
  before_filter :allowed_publisher_network_login, 
                :only => [:edit, :show, :update, :destroy]
  before_filter :find_user_networks

  def index


    # any conditions to filter by?
    conditions = {}
    %w[publisher_id network_id].each do |id|
        if ! params[id].blank?
            conditions[id] = params[id]
        end
    end        

    ### an admin wants to see a different list of publishers?
    if current_user.admin? and !params["publisher_id"].blank? 
        @loop_publishers = [ Publisher.find_by_id( params["publisher_id"] ) ]
    else
        @loop_publishers = @publishers
    end        
    
    ### limit to this network? has to be done in the template, as it's
    ### in a tight loop
    if !params["network_id"].blank? 
        @limit_to_network_id = params["network_id"]
    end
    
  end
  
  def show
  end
  
  def new   
    @publisher_network_login = PublisherNetworkLogin.new
  end
  
  def create
    @publisher_network_login = PublisherNetworkLogin.new(params[:publisher_network_login])
    if @publisher_network_login.save
      flash[:notice] = "Successfully created publisher network login."
      redirect_to @publisher_network_login
    else
      render :action => 'new'
    end
  end
  
  def edit
  end
  
  def update
    if @publisher_network_login.update_attributes(params[:publisher_network_login])
      flash[:notice] = "Successfully updated publisher network login."
      redirect_to publisher_network_logins_url
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    @publisher_network_login.destroy
    flash[:notice] = "Successfully destroyed publisher network login."
    redirect_to publisher_network_logins_url
  end
    
    ### load the publisher_network_login if allowed
    def allowed_publisher_network_login
        conditions = {}
        if !current_user.admin? 
            if !current_publisher
                require_admin
            else                 
                conditions[:publisher_id] = current_publisher.id   
            end
        end
        
        @publisher_network_login = PublisherNetworkLogin.find_by_id( 
                                        params[:id], :conditions => conditions )

        ### nothing found? you probably dont have permission                                        
        require_admin if !@publisher_network_login
    end        
end
