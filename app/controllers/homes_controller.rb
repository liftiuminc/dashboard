class HomesController < ApplicationController
  before_filter :require_user, :only => ["publisher", "admin"]
  before_filter :require_admin, :only => ["admin"]

  def index
    if current_user 
      if current_user.publisher
        render :publisher
      elsif current_user.admin 
        render :admin
      end
    end
    # not logged in, render home
  end

  def admin
  end

  def publisher
  end

end
