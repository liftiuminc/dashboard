# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  #protect_from_forgery # See ActionController::RequestForgeryProtection for details

  ### for email exceptions. See FB 60
  ### not yet working, disabled for now --jos
  #include ExceptionNotifiable

  # Scrub sensitive parameters from your log
  filter_parameter_logging :password, :password_confirmation

  # Auth logic http://github.com/binarylogic/authlogic_example
  helper_method :current_user_session, :current_user

  private
    def current_user_session
      return @current_user_session if defined?(@current_user_session)
      @current_user_session = UserSession.find
    end

    def current_user
      return @current_user if defined?(@current_user)
      @current_user = current_user_session && current_user_session.user
    end

    def current_publisher
        return @current_publisher if defined?(@current_publisher)
        
        if @current_user and @current_user.publisher
            @current_publisher = @current_user.publisher
        end
    end        

    def require_user
      unless current_user
        store_location
        flash[:notice] = "You must be logged in to access this page"
        redirect_to new_user_session_url
        return false
      end
    end
 
    def require_no_user
      if current_user
        store_location
        flash[:notice] = "You must be logged out to access this page"
        redirect_to account_url
        return false
      end
    end
    
    def store_location
      session[:return_to] = request.request_uri
    end
    
    def redirect_back_or_default(default)
      redirect_to(session[:return_to] || default)
      session[:return_to] = nil
    end

    def require_admin
      unless current_user
        store_location
        flash[:notice] = "You must be logged in to access this page"
        redirect_to new_user_session_url
        return false
      end
      if !current_user.admin?
        permission_denied ("You must be an administrator to access this page")
        return false
      end
    end

    def permission_denied (msg)
	flash[:notice] = msg
        render(:file => 'public/403.html', :status => :forbidden)
    end
    
    ### XXX FIXME -- these should probably live Elsewhere(tm) -jos
    def find_enabled_networks
      @networks = Network.find  :all, 
                                :conditions => {:enabled => true},
                                :order => "network_name ASC"
    end
    
    def find_user_networks
      if !current_user.admin? 
        if current_publisher
          ### XXX FIXME there is probably a more ActiveRecordy way to handle this 
          @networks = Network.find_by_sql(["SELECT * FROM networks WHERE id IN (SELECT network_id FROM tags where publisher_id = ? AND enabled = ? ORDER BY network_name ASC)", current_publisher.id, 1])
        else 
          require_admin
        end
      else
        find_enabled_networks
      end
    end

    def find_user_adformats
      if !current_user.admin? 
        if current_publisher
          ### XXX FIXME there is probably a more ActiveRecordy way to handle this 
          @adformats = AdFormat.find_by_sql(["SELECT * FROM ad_formats WHERE size IN (SELECT size FROM tags where publisher_id = ? AND enabled = ? ORDER BY ad_format_name ASC)", current_publisher_id, 1])        
        else 
          require_admin
        end
      else
        @adformats = AdFormat.all :order => "ad_format_name ASC"
      end
    
    end

    def find_all_publishers
      @publishers = Publisher.find :all, :order => 'site_name ASC';
    end

    ### the list of publishers accessible to this user
    def allowed_publishers
        if !current_user.admin? 
            @publishers = [ current_publisher ]
        else 
            # Get the list of publishers for admin users
            find_all_publishers
        end
    end  
end
