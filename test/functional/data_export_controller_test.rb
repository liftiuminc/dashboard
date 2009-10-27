require 'test_helper'

class DataExportControllerTest < ActionController::TestCase
  setup :activate_authlogic

  context "index action NOT logged in" do
    setup { get :index }
    should_redirect_to "login url" do
      new_user_session_url
    end
  end

  context "index action" do
    should "render index template" do
      login_as_admin
      get :index
      assert_template 'index'
    end
  end

  context "create action" do
    should "render create template" do
      login_as_admin
      get :create, :network_id => "1", :interval => "day"
      assert_template 'create'
    end
  end

  context "create action with csv, minute" do
    should "respond with csv data type" do
      login_as_admin
      get :create, :network_id => "1", "format" => "csv"
      respond_with_content_type 'text/csv'
    end
  end

  context "create action with csv, daily" do
    should "respond with csv data type" do
      login_as_admin
      get :create, :network_id => "1", :format => "csv", :interval => "day"
      respond_with_content_type 'text/csv'
    end
  end

  # Fix bug reported by Jennie where if you do a search that doesn't return results with CSV, it should redirect you back
  context "create action with query that won't return results" do
    should "render index template" do
      login_as_admin
      get :create, :network_id => "100000000000", "format" => "csv"
      respond_with_content_type 'text/html'
    end
  end

  # Admin vs publisher
  context "index action with a admin login" do
    setup do
      login_as_admin
      get :index
    end
    should_assign_to :publishers
  end

  context "index action with a publisher login" do
    setup do
      login_as_publisher
      get :index
    end
    should_not_assign_to :publishers
  end

end
