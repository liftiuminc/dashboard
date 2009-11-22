class JavascriptErrorsController < ApplicationController
  def index
    @javascript_errors = JavascriptError.all(:limit => 100, :order => "created_at DESC")
  end
  
  def show
    @javascript_error = JavascriptError.find(params[:id])
  end
end
