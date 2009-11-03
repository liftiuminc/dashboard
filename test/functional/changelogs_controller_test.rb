require 'test_helper'

class ChangelogsControllerTest < ActionController::TestCase
  setup :activate_authlogic

  context "index action NOT logged in" do
    setup do
      @network = Network.find(:first)
      @tag = Tag.find(:first)
      @network.update_attribute(:network_name, @new_network_name = "NewNetworkName")
      @tag.update_attribute(:tag_name, @new_tag_name = "NewTagName")
    end

    should_redirect_to "login url" do
      get :index
      new_user_session_url
    end

    should "render the index template" do
      login_as_admin
      get :index
      assert_template :index
      assert_not_nil assigns(:changelogs)
      assert_match @new_network_name, @response.body
      assert_match @new_tag_name, @response.body
    end

    should "filter by record id and record type if params are passed" do
      login_as_admin

      get :index, :record_id => @network.id, :record_type => "Network"
      assert_template :index
      assert_not_nil assigns(:changelogs)
      assert_match @new_network_name, @response.body
      assert_no_match Regexp.new(@new_tag_name), @response.body
    end
  end
end
