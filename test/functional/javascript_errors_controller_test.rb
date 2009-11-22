require 'test_helper'

class JavascriptErrorsControllerTest < ActionController::TestCase
  setup :activate_authlogic

  context "index action" do
    context "index action NOT logged in" do
      should_redirect_to "login url" do
        get :index
        new_user_session_url
      end
    end
  end

  context "index action as publisher" do
    should "render index template" do
      login_as_publisher
      get :index
      assert_template 'index'
    end
  end

  context "index action as admin" do
    should "render index template" do
      login_as_admin
      get :index
      assert_template 'index'
    end
  end

  context "show action" do
    should "render show template" do
      login_as_admin
      get :show, :id => JavascriptError.first
      assert_template 'show'
    end
  end


end
