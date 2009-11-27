# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def liftium_submit(text="Submit")
	submit_tag text
  end
  
  def external_form_post( label = "Submit", action = '', params = {} )
    form = "<form action='#{action}' method='post' target='_blank'>"

    params.each do|k, v|
      form += hidden_field_tag k, v
    end
    
    form += "<input type='submit' value='#{label}'>"
    form += "</form>"
    
    return form
  end

  # alternate version of the above that uses javascript form instead of inline form (handy if you are already in a form)
  def external_form_post_js( label = "Submit", action = '', params = {} )
    return "<input type='button' value='#{label}' onClick='externalFormPost(" + action.to_json + "," +  params.to_json + ")'/>"
  end

  #http://transfs.com/devblog/2009/06/26/nested-forms-with-rails-2-3-helpers-and-javascript-tricks/
  def generate_html(form_builder, method, options = {})
    options[:object] ||= form_builder.object.class.reflect_on_association(method).klass.new
    options[:partial] ||= method.to_s.singularize
    options[:form_builder_local] ||= :f
 
    form_builder.fields_for(method, options[:object], :child_index => 'NEW_RECORD') do |f|
      render(:partial => options[:partial], :locals => { options[:form_builder_local] => f })
    end
  end
 
  def link_to_new_nested_form(name, form_builder, method, options = {})
    options[:object] ||= form_builder.object.class.reflect_on_association(method).klass.new
    options[:partial] ||= method.to_s.singularize
    options[:form_builder_local] ||= :f
    options[:element_id] ||= method.to_s
    options[:position] ||= :bottom
    link_to_function name do |page|
      html = generate_html(form_builder,
                    method,
                    :object => options[:object],
                    :partial => options[:partial],
                    :form_builder_local => options[:form_builder_local]
                   )
      page << %{
        $('#{options[:element_id]}').insert({ #{options[:position]}: "#{ escape_javascript html }".replace(/NEW_RECORD/g, new Date().getTime()) });
      }
    end
  end
end
