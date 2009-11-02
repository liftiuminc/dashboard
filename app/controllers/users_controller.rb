class UsersController < ApplicationController
  # before_filter :require_no_user, :only => [:new, :create]
  before_filter :require_user,      :only => [:show, :edit, :update, :destroy]
  before_filter :require_admin,     :only => [:new, :index, :create ]
  before_filter :allowed_user
  before_filter :allowed_publishers

  def index
    @users = User.all
  end
  
  def show
  end
  
  def new
    @user = User.new
  end
  
  def create
    @user = User.new(params[:user])
    if @user.save
      flash[:notice] = "Successfully created user."
      redirect_to @user
    else
      render :action => 'new'
    end
  end
  
  def edit
  end
  
  def update
    if @user.update_attributes(params[:user])
      flash[:notice] = "Successfully updated user."
      redirect_to users_url
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    @user.destroy
    flash[:notice] = "Successfully destroyed user."
    redirect_to users_url
  end
  
    ### load the user you're allowed to load
    def allowed_user
        if !current_user.admin? or !params[:id]
            @user = current_user
        else params[:id] 
            @user = User.find(params[:id])
        end
    end     
end
