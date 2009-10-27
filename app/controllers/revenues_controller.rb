class RevenuesController < ApplicationController
  before_filter :require_admin 

  def index
    @revenues = Revenue.all
  end
  
  def show
    @revenue = Revenue.find(params[:id])
  end
  
  def new
    @revenue = Revenue.new
  end
  
  def create
    @revenue = Revenue.new(params[:revenue])
    if @revenue.save
      flash[:notice] = "Successfully created revenue."
      redirect_to @revenue
    else
      render :action => 'new'
    end
  end
  
  def edit
    @revenue = Revenue.find(params[:id])
  end
  
  def update
    @revenue = Revenue.find(params[:id])
    if @revenue.update_attributes(params[:revenue])
      flash[:notice] = "Successfully updated revenue."
      redirect_to @revenue
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    @revenue = Revenue.find(params[:id])
    @revenue.destroy
    flash[:notice] = "Successfully destroyed revenue."
    redirect_to revenues_url
  end
end
