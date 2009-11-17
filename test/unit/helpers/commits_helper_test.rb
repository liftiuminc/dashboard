require 'test_helper'

class CommitsHelperTest < ActionView::TestCase
  def test_commits_title_no_filter
    assert_equal "Changelogs - Showing all entries", commits_title({})
  end

  def test_commits_title_filter_by_record_id_and_record_type
    assert_equal "Changelogs - Filtered by Network with id 1 (<a href=\"/commits\">Show All</a>)",
                 commits_title({:record_id => 1, :record_type => "Network"})
  end

  def test_commits_title_filter_by_user_id
    assert_equal "Changelogs - Filtered by nick@liftium.com's changes (<a href=\"/commits\">Show All</a>)",
                 commits_title({:user_id => users(:nick).id})
  end

  def test_commits_title_filter_by_user_id_not_found_shows_all
    assert_equal "Changelogs - Showing all entries", commits_title({:user_id => nil})
  end

  def test_commits_title_excluded_users
    assert_equal "Changelogs - Showing all entries excluding nick@liftium.com (<a href=\"/commits\">Show All</a>)",
                 commits_title({:excluded_user_id => 42})
  end
end
