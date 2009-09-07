# Auth logic user session set up pulled from:
# http://github.com/binarylogic/authlogic_example/blob/5819a13477797d758cb6871f475ed1c54bf8a3a7/app/controllers/application_controller.rb

class ApplicationController < ActionController::Base
  helper :all
  helper_method :current_user_session, :current_user
  filter_parameter_logging :password, :password_confirmation
  
  # Active scaffold config
  ActiveScaffold.set_defaults do |config| 
    config.ignore_columns.add [:created_at, :updated_at]
  end
  
  private
    def current_user_session
      return @current_user_session if defined?(@current_user_session)
      @current_user_session = UserSession.find
    end
    
    def current_user
      return @current_user if defined?(@current_user)
      @current_user = current_user_session && current_user_session.record
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
end
