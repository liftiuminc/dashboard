class UsersController < ApplicationController
  # before_filter :require_no_user, :only => [:new, :create]
  before_filter :require_user,      :only => [:show, :edit, :update, :destroy, :new_change_password, :change_password]
  before_filter :require_admin,     :only => [:new, :index, :create]
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
      redirect_to users_path
    else
      render :action => 'edit'
    end
  end

  def destroy
    @user.destroy
    flash[:notice] = "Successfully destroyed user."
    redirect_to users_path
  end

  def new_change_password
  end

  def change_password
    unless @user.valid_password?(params[:old_password])
      flash[:error].now = "Your current password was not correct."
      render :action => :new_change_password
      return
    end

    if (!params[:user][:password].blank? && !params[:user][:password_confirmation].blank?) && @user.update_attributes(params[:user])
      flash[:notice] = "Your password has been successfully changed."
      redirect_to user_path(@user)
    else
      flash.now[:error] = "Your new passwords did not match."
      render :action => :new_change_password
      return
    end
  end

  private
  def allowed_user
    if !current_user.is_admin? or !params[:id]
      @user = current_user
    else params[:id]
      @user = User.find(params[:id])
    end
  end
end
