require 'test_helper'

class PublisherTagsControllerTest < ActionController::TestCase
  setup :activate_authlogic

  context "index action NOT logged in" do
    setup { get :index }
    should_redirect_to "login url" do
      new_user_session_url
    end
  end

  context "index action" do
    should "render index template" do
      login_as_publisher
      get :index
      assert_template 'index'
    end
  end

end
