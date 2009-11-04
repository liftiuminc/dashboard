require 'json'
module ChangelogsHelper

  def render_diffs(changelog)
    JSON.parse(changelog.diff).inject([]) do |arr, hsh|
      arr << changed_txt(hsh[0], hsh[1][0], hsh[1][1])
    end.compact.join("<br/>")
  end

  def render_user(changelog)
    if changelog.user && user = User.find(changelog.user_id)
      [link_to(user.email, user_path(user)),
       link_to("Filter", changelogs_path(:user_id => user.id))
      ].join("<br/>")
    else
      "N/A"
    end
  end

  def render_changelog_links(changelog)
    [link_to("Show Original", changelog.record), link_to("Show changelogs for this object", changelogs_path(:record_id => changelog.record_id, :record_type => changelog.record_type))].join(" | ")
  end

  def changelogs_title(params)
    if params[:record_id] && params[:record_type]
      "Changelogs - Filtered by #{params[:record_type]} with id #{params[:record_id]} (#{link_to("Show All", changelogs_path)})"
    elsif params[:user_id] && user = User.find_by_id(params[:user_id])
      "Changelogs - Filtered by #{user.email}'s changes (#{link_to("Show All", changelogs_path)})"
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

  private

  def changed_txt(attribute, original_value, new_value)
    return if original_value.blank? && new_value.blank?
    retval = "<b>#{attribute}</b> "
    retval += original_value.blank? ? "initialized to <i>#{new_value}</i>" : "changed from <i>#{original_value}</i> to <i>#{new_value}</i>"
  end
end
