class ApiController < ApplicationController

  def update_tag 
    if !params[:id] 
      die_with_error("Must supply a tag id");

    else  
      params[:id] ||= params[:tag_id] 
      @tag = Tag.find(params[:id])
      
      tagParams = {}
      for key in @tag.attribute_names do
        tagparams[key] = params[key] if params[key]
      end

      if @tag.update_attributes(tagParams)
        respond_to do |format|
          format.html { render :text => @tag.inspect, :content_type => "text/plain" }
          format.json { render :json => @tag.to_json }
          format.xml { render :xml => @tag.to_xml }
        end  
      else 
        die_with_error(@tag.errors)
      end
    end
  end

  def die_with_error (msg)
    respond_to do |format|
      format.html { render :text => msg.inspect, :content_type => "text/plain" }
      format.json { render :json => msg.to_json }
      format.xml { render :xml => msg.to_xml }
    end  
  end

end
