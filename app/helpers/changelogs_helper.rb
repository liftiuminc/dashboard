module ChangelogsHelper

  def render_diffs(changelog)
    JSON.parse(changelog.diff).inject([]) do |arr, hsh|
      arr << changed_txt(hsh[0], hsh[1][0], hsh[1][1])
    end.compact.join("<br/>")
  end

  def render_user(changelog)
    if changelog.user
      user = User.find(changelog.user_id)
      link_to user.email, user_path(user)
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
    else
      "Changelogs - Showing All"
    end
  end

  private

  def changed_txt(attribute, original_value, new_value)
    return if original_value.blank? && new_value.blank?
    retval = "<b>#{attribute}</b> "
    retval += original_value.blank? ? "initialized to <i>#{new_value}</i>" : "changed from <i>#{original_value}</i> to <i>#{new_value}</i>"
  end
end
