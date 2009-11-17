require 'test_helper'

class ChangelogsControllerTest < ActionController::TestCase
  setup :activate_authlogic

  setup do
    ChangelogSession.begin
  end

  teardown do
    ChangelogSession.end
  end

  context "show" do
    context "NOT logged in" do
      should_redirect_to "login url" do
        get :show
        new_user_session_url
      end
    end

    context "logged in" do
      should "render the changelog show template" do
        nick = users(:nick)
        login_as(nick)
        Changelog.current_user = nick
        changelog = Changelog.create!(:record_id => tags(:lb_reject).id, :record_type => "Tag", :user_id => nick.id,
                                      :description => "Description",
                                      :diff => '{"size":["120x20","728x90"],"created_at":["2009-10-01T00:20:11Z","2009-11-01T00:20:11Z"]}')

        get :show, :id => changelog.id
        assert_template :show
        assert_equal changelog, assigns(:changelog)
      end
    end
  end
end
