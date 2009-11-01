require 'test_helper'

class ChangelogsControllerTest < ActionController::TestCase
  setup :activate_authlogic

  context "index action NOT logged in" do
    should_redirect_to "login url" do
      get :index
      new_user_session_url
    end

    should "render the index template" do
      login_as_admin
      get :index
      assert_template :index
      assert_not_nil assigns(:changelogs)
    end
  end
end
