# These helper methods can be called in your template to set variables to be used in the layout
# This module should be included in all views globally,
# to do so you may need to add this line to your ApplicationController
#   helper :layout
module LayoutHelper
  def title(page_title, show_title_bar = true)
    @content_for_title = page_title.to_s
    @show_title_bar = show_title_bar
  end
  
  def show_title_bar?
    @show_title_bar
  end
  
  def stylesheet(*args)
    content_for(:head) { stylesheet_link_tag(*args) }
  end
  
  def javascript(*args)
    content_for(:head) { javascript_include_tag(*args) }
  end

  def date_range_dropdown (firstOption = "")
	out = '<select name="date_select" id="date_selectDD" onChange="window.dateSelect && dateSelect(this)">
		<option value="">' + firstOption +
		options_for_select(DateRangeHelper.timeframes, params[:date_select]) +
              '</select>'
  end

  def publisher_dropdown (firstOption = "")
	publishers = @publishers || Publisher.all(:order => "site_name")
	out = '<select name="publisher_id" id="publisher_selectDD" onChange="window.publisherSelect && publisherSelect(this)">
		<option value="">' + firstOption +
		options_from_collection_for_select(publishers, "id", "site_name", params[:publisher_id]) +
              '</select>'
  end

  def date_range_to_graph_range (date_range)
     case date_range.to_s.downcase
	when "this hour" then "1h"
	when "last hour" then "2h"
	when "last 3 hours" then "3h"
	when "last 12 hours" then "12h"
	when "today" then "1d"
	when "yesterday" then "2d"
	when "last 7 days" then "1w"
	when "this month" then Time.now.strftime("%M").to_s + "d"
	when "last 30 days" then "30d"
	when "this quarter" then "3m"
	when "last quarter" then "6m"
	when "this year" || "all time" then "1y"
        else "1h"
     end
  end

  def percentage_difference (from, to)
   if (! diff = calc_percentage_difference(from, to)) 
      return ""
   end 

   if from < to 
     return "<span style='color: green'>UP " + diff.to_s + "%</span>"
   elsif from > to 
     return "<span style='color: red'>DOWN " + diff.to_s + "%</span>"
   else
     return ""
   end 
 end

 def calc_percentage_difference (from, to)
   from = from.to_f
   to = to.to_f
   if from <= 0 || to <= 0
     # not going to work out
     return 0.to_f
   end 

   if from < to 
     return ((from-to)/from * -100).to_f.round(1)
   elsif from > to 
     return  ((to-from)/from * 100).to_f.round(1)
   else
     return 0.to_f
   end 
 end 
end
