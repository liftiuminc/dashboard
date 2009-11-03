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

  def test_render_nothing_when_set_to_empty_string
    changelog = Changelog.new(:diff => '{"comments":[null,""],"tag_template":[null,""]}')
    assert_equal '', render_diffs(changelog)
  end

  def test_render_user
    user = User.find(:first)
    changelog = Changelog.new(:user_id => user.id)
    assert_equal "<a href=\"/users/#{user.id}\">#{user.email}</a>", render_user(changelog)
  end

  def test_render_changelog_links
    changelog = Changelog.new(:record_id => 1, :record_type => "Network")
    assert_equal "<a href=\"/networks/1\">Show Original</a> | <a href=\"/changelogs?record_id=1&amp;record_type=Network\">Show changelogs for this object</a>", render_changelog_links(changelog)
  end

  def test_changelogs_title_no_filter
    assert_equal "Changelogs - Showing All", changelogs_title({})
  end

  def test_changelogs_title_filter_by_record_id_and_record_type
    assert_equal "Changelogs - Filtered by Network with id 1 (<a href=\"/changelogs\">Show All</a>)", 
                 changelogs_title({:record_id => 1, :record_type => "Network"})
  end
end
