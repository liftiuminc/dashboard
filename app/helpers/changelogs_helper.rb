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
       link_to("Filter", changelogs_path(:user_id => user.id))
      ].join("<br/>")
    else
      "N/A"
    end
  end

  def render_changelog_links(changelog)
    [link_to("View", changelog_path(changelog)),
     link_to("Original", changelog.record),
     link_to("All changelogs", commits_path(:record_id => changelog.record_id, :record_type => changelog.record_type))].join(" | ")
  end

  def distinct_changelog_users_for_select
    results = User.find_by_sql("SELECT id, email FROM users WHERE id IN (SELECT distinct(user_id) FROM changelogs)")
    results.collect{|u|[u.email, u.id]}.unshift(["none"])
  end

  def commit_text(commit)
    "#{pluralize(commit.changelogs.size, "Change")} by #{commit.user_name} on #{commit.created_at}"
  end

  private

  def changed_txt(attribute, original_value, new_value, truncate = false)
    return if original_value.blank? && new_value.blank?

    if truncate
      original_value = truncate(original_value.to_s, :length => 30)
      new_value = truncate(new_value.to_s, :length => 30)
    end


    retval = "<b>#{attribute}</b> "
    retval += original_value.blank? ? "initialized to <i>#{new_value}</i>" :
        "changed from <i>#{original_value}</i> to <i>#{new_value}</i>"
  end
end
