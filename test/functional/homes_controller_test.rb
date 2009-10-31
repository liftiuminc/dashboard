require 'test_helper'

class HomesControllerTest < ActionController::TestCase
  setup :activate_authlogic

  context "index action NOT logged in" do
    setup { get :index }
    should "render index template" do
      assert_template 'index'
    end
  end

#  context "index action logged in as admin" do
#    should_redirect_to "admin home" do
#	"/homes/admin"
#    end
#  end

#  context "publisher action logged in as publisher" do
#    should_redirect_to "publisher home" do
#	publisher_homes_url
#    end
#  end

  context "admin action NOT logged in" do
    setup { get :admin }
    should_redirect_to "login url" do
      new_user_session_url
    end
  end

  context "publisher action NOT logged in" do
    setup { get :publisher }
    should_redirect_to "login url" do
      new_user_session_url
    end
  end

  context "admin action logged in as PUBLISHER" do
    should "render 403" do
      login_as_publisher
      get :admin 
      assert_template "public/403.html"
      respond_with "403"
    end
  end
 
end
