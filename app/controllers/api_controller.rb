class ApiController < ApplicationController

  def update_tag 
    if !params[:tag_id] 
      die_with_error("Must supply a tag_id");

    else  
      @tag = Tag.find(params[:tag_id])
      
      tagParams = {}
      for key in @tag.attribute_names do
        tagParams[key] = params[key] if params[key]
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
    amsg = {"error" => msg}
    respond_to do |format|
      format.html { render :text => amsg.inspect, :content_type => "text/plain" }
      format.json { render :json => amsg.to_json }
      format.xml { render :xml => amsg.to_xml }
    end  
  end

end
