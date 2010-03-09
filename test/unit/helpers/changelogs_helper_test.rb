require 'test_helper'

class ChangelogsHelperTest < ActionView::TestCase

  def test_render_diffs_shows_nothing_when_set_to_empty_string
    changelog = Changelog.new(:diff => '{"comments":[null,""],"tag_template":[null,""]}')
    assert_equal '', render_diffs(changelog)
  end

  def test_render_user_renders_na_when_no_user
    changelog = Changelog.new
    assert_equal "N/A", render_user(changelog)
  end

  def test_changelogs_title_no_filter
    assert_equal "Changelogs - Showing all entries", changelogs_title({})
  end

  def test_changelogs_title_filter_by_record_id_and_record_type
    # assert_equal "Changelogs - Filtered by Network with id 1 (<a href=\"/changelogs\">Show All</a>)",
                 changelogs_title({:record_id => 1, :record_type => "Network"})
  end

  def test_changelogs_title_filter_by_user_id
    #assert_equal "Changelogs - Filtered by nick@liftium.com's changes (<a href=\"/changelogs\">Show All</a>)",
                 changelogs_title({:user_id => users(:nick).id})
  end

  def test_changelogs_title_filter_by_user_id_not_found_shows_all
    assert_equal "Changelogs - Showing all entries", changelogs_title({:user_id => nil})
  end

  def test_changelogs_title_excluded_users
    assert_equal "Changelogs - Showing all entries excluding nick@liftium.com (<a href=\"/changelogs\">Show All</a>)",
                 changelogs_title({:excluded_user_id => 42})
  end

  def test_distinct_changelog_users_for_select
    nick = User.find_by_id(42)
    Changelog.current_user = nick
    changelog = Changelog.create!(:record_id => 1, :record_type => "Tag", :user_id => nick.id,
                                  :diff => '{"size":["120x20","728x90"],"created_at":["2009-10-01T00:20:11Z","2009-11-01T00:20:11Z"]}')

    assert_equal [["none"], ["nick@liftium.com", 42]], distinct_changelog_users_for_select
  end
end
