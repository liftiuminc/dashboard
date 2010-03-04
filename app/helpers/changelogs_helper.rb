require 'json'
module ChangelogsHelper

  def render_diffs(changelog, truncate = false)
    JSON.parse(changelog.diff).inject([]) do |arr, hsh|
      arr << changed_txt(hsh[0], hsh[1][0], hsh[1][1], truncate)
    end.compact.join("<br/>")
  end

  def render_user(changelog)
    if changelog.user && user = User.find(changelog.user_id)
      [link_to(user.email, user_path(user)),
       link_to("Filter by User", changelogs_path(:user_id => user.id))
      ].join("<br/>")
    else
      "N/A"
    end
  end

  def render_changelog_links(changelog)
    [link_to("View Full Change", changelog), link_to("Original Record", changelog.record)].join(" | ")
  end

  def changelogs_title(params)
    if params[:record_id] && params[:record_type]
      "Changelogs - Filtered by #{params[:record_type]} with id ##{params[:record_id]}"
    elsif params[:user_id] && user = User.find_by_id(params[:user_id])
      "Changelogs - Filtered by #{user.email}'s changes)"
    else
      title = "Changelogs - Showing #{@entries || "all"} entries"
      title += " excluding #{User.find_by_id(params[:excluded_user_id]).email} (#{link_to("Show All", changelogs_path)})" if params[:excluded_user_id] && params[:excluded_user_id] != "none"
      title
    end
  end

  def distinct_changelog_users_for_select
    results = User.find_by_sql("SELECT id, email FROM users WHERE id IN (SELECT distinct(user_id) FROM acts_as_changelogs)")
    results.collect{|u|[u.email, u.id]}.unshift(["none"])
  end

  def changelog_link(object, text="Log")
    if object.nil?
       return ""
    end
    link_to text, :controller=> "changelogs", :record_id => object.id, :record_type => object.class.to_s
  end 

  private

  def changed_txt(attribute, original_value, new_value, truncate = false)
    return if original_value.blank? && new_value.blank?

    # Skip certain columns
    return if ["id", "created_at", "updated_at"].include?(attribute)

    original_value = h(original_value.to_s)
    new_value = h(new_value.to_s)

    retval = "<b>#{attribute}</b> "
    retval += original_value.blank? ? "set to <i style='white-space: pre'>#{new_value}</i>" :
        "changed from <i style='white-space: pre'>#{original_value}</i> <b>to</b> <i style='white-space: pre'>#{new_value}</i>"
  end
end
