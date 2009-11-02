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

  def render_show_link(changelog)
    link_to "Show", changelog.record
  end

  private

  def changed_txt(attribute, original_value, new_value)
    return if original_value.blank? && new_value.blank?
    retval = "<b>#{attribute}</b> "
    retval += original_value.blank? ? "initialized to <i>#{new_value}</i>" : "changed from <i>#{original_value}</i> to <i>#{new_value}</i>"
  end
end
