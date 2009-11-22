class JavascriptErrorsController < ApplicationController
  before_filter :require_user
  before_filter :allowed_publishers

  ### setting this does not seem to work with a proc.. riddle me this ;(  
  def set_limit
    @limit = 250
  end

    
  def index
    if current_user.is_admin?
	if params[:publisher_id] && !params[:publisher_id].empty?
	   conditions = ["publisher_id = ?", params[:publisher_id]]
	else 
	   conditions = ["publisher_id > ?", 0]
	end
    else 
	conditions = ["publisher_id = ?", current_user.publisher.id]
    end
    @javascript_errors = JavascriptError.all(:limit => 100, :order => "created_at DESC", :conditions => conditions)
  end
 
  def grouped_by

    if current_user.is_admin?
	if params[:publisher_id] && !params[:publisher_id].empty?
	   pubidWhere = "publisher_id = " + params[:publisher_id].to_i.to_s
	else 
	   pubidWhere = "1=1"
	end
    else 
	pubidWhere = "publisher_id = " + current_user.publisher.id.to_s
    end

    case params[:field]
      when "tag" then @field = "tag_id"
      when "message" then @field = "message"
      when "publisher" then @field = "publisher_id"
      when "url" then @field = "url"
      else @field = "tag_id"
    end

    @javascript_errors = JavascriptError.find_by_sql(["SELECT *, count(#{@field}) AS field_count" +
	" FROM javascript_errors WHERE " + pubidWhere +
	" AND #{@field} != ''" +
	" GROUP by #{@field} ORDER BY field_count DESC"])
	
  end

  def show
    @javascript_error = JavascriptError.find(params[:id])
  end

end
