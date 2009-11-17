require 'test_helper'

class ChangelogsControllerTest < ActionController::TestCase
  setup :activate_authlogic

  context "index" do
    setup do
      ChangelogSession.begin
      @network = networks(:Adsense)
      @tag = tags(:lb_reject)
      @network.update_attribute(:network_name, "NewNetworkName")
      @tag.update_attribute(:tag_name, "NewTagName")
    end

    teardown do
      ChangelogSession.end
    end

    context "NOT logged in" do
      should_redirect_to "login url" do
        get :index
        new_user_session_url
      end
    end

    context "logged in" do
      should "render the index template" do
        login_as_admin
        get :index
        assert_template :index
        assert_not_nil assigns(:changelogs)
      end

      should "filter by record id and record type if params are passed" do
        login_as_admin
        get :index, :record_id => @network.id, :record_type => "Network"
        assert_template :index
        assert_not_nil assigns(:changelogs)
        assert_match "Filtered by Network with id 1", @response.body
      end
    end
  end

  context "show" do
    setup do
      ChangelogSession.begin
    end

    teardown do
      ChangelogSession.end
    end
    
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
