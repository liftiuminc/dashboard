require 'test_helper'

class ChangelogsHelperTest < ActionView::TestCase

  def test_render_diffs_for_create
    changelog = Changelog.new(:diff => '{"size":[null,"728x90"],"created_at":[null,"2009-11-01T00:20:11Z"]}')
    assert_equal '<b>created_at</b> initialized to <i>2009-11-01T00:20:11Z</i><br/><b>size</b> initialized to <i>728x90</i>',
                  render_diffs(changelog)
  end

  def test_render_diffs_for_update
    changelog = Changelog.new(:diff => '{"size":["120x20","728x90"],"created_at":["2009-10-01T00:20:11Z","2009-11-01T00:20:11Z"]}')
    assert_equal '<b>created_at</b> changed from <i>2009-10-01T00:20:11Z</i> to <i>2009-11-01T00:20:11Z</i><br/><b>size</b> changed from <i>120x20</i> to <i>728x90</i>',
                  render_diffs(changelog)
  end

  def test_render_diffs_truncates_long_diffs_to_30
    changelog = Changelog.new(:diff => "{\"something\":[null, \"#{"T" * 80}\"]}")
    assert_equal "<b>something</b> initialized to <i>#{"T" * 27}...</i>", render_diffs(changelog, truncate = true)
  end

  def test_render_diffs_truncate_handles_fixnums
    changelog = Changelog.new(:diff => "{\"something\":[null, 80]}")
    assert_equal "<b>something</b> initialized to <i>80</i>", render_diffs(changelog, truncate = true)
  end

  def test_render_diffs_shows_nothing_when_set_to_empty_string
    changelog = Changelog.new(:diff => '{"comments":[null,""],"tag_template":[null,""]}')
    assert_equal '', render_diffs(changelog)
  end

  def test_render_user
    user = users(:nick)
    changelog = Changelog.new(:user_id => user.id)
    assert_equal "<a href=\"/users/#{user.id}\">#{user.email}</a><br/><a href=\"/commits?user_id=#{user.id}\">Filter</a>", render_user(changelog)
  end

  def test_render_user_renders_na_when_no_user
    changelog = Changelog.new
    assert_equal "N/A", render_user(changelog)
  end

  def test_render_changelog_links
    ChangelogSession.begin
    changelog = Changelog.create!(:record_id => 1, :record_type => "Network")
    ChangelogSession.end
    assert_equal "<a href=\"/changelogs/#{changelog.id}\">View</a> | <a href=\"/networks/1\">Original</a> | <a href=\"/changelogs?record_id=1&amp;record_type=Network\">All changelogs</a>", render_changelog_links(changelog)
  end

  def test_distinct_changelog_users_for_select
    nick = users(:nick)
    Changelog.current_user = nick
    ChangelogSession.begin
    changelog = Changelog.create!(:record_id => 1, :record_type => "Tag", :user_id => nick.id,
                                  :diff => '{"size":["120x20","728x90"],"created_at":["2009-10-01T00:20:11Z","2009-11-01T00:20:11Z"]}')
    ChangelogSession.end
    assert_equal [["none"], ["nick@liftium.com", 42]], distinct_changelog_users_for_select
  end
end
