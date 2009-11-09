require 'test_helper'

class PublishersControllerTest < ActionController::TestCase
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
  
  context "show action" do
    should "render show template" do
      login_as_admin
      get :show, :id => Publisher.first
      assert_template 'show'
    end
  end
  
  context "new action" do
    should "render new template" do
      login_as_admin
      get :new
      assert_template 'new'
    end
  end
  
  context "create action" do
    should "render new template when model is invalid" do
      login_as_admin
      Publisher.any_instance.stubs(:valid?).returns(false)
      post :create
      assert_template 'new'
    end
    
    should "redirect when model is valid" do
      login_as_admin
      Publisher.any_instance.stubs(:valid?).returns(true)
      post :create
      assert_redirected_to publisher_url(assigns(:publisher))
    end
  end
  
  context "edit action" do
    should "render edit template" do
      login_as_admin
      get :edit, :id => Publisher.first
      assert_template 'edit'
    end
  end
  
  context "update action" do
    should "render edit template when model is invalid" do
      login_as_admin
      Publisher.any_instance.stubs(:valid?).returns(false)
      put :update, :id => Publisher.first
      assert_template 'edit'
    end
  
    should "redirect when model is valid" do
      login_as_admin
      Publisher.any_instance.stubs(:valid?).returns(true)
      put :update, :id => Publisher.first
      assert_redirected_to publishers_url
    end
  end
  
  context "destroy action" do
    should "destroy model and redirect to index action" do
      login_as_admin
      publisher = Publisher.first
      delete :destroy, :id => publisher
      assert_redirected_to publishers_url
      assert !Publisher.exists?(publisher.id)
    end
  end

  context "ad_preview action" do
    should "render ad_preview template" do
      login_as_publisher
      get "ad_preview"
      assert_template 'ad_preview'
    end
  end

  context "ad_formats action as publisher" do
    should "render ad_formats template" do
      login_as_publisher
      get "ad_formats"
      assert_template 'ad_formats'
    end
  end

  context "ad_formats action as admin" do
    should "render ad_formats template" do
      login_as_admin
      get "ad_formats", :publisher_id => "1"
      assert_template 'ad_formats'
    end
  end

  context "quality_control action as publisher" do
    should "render quality_control template" do
      login_as_publisher
      get "quality_control"
      assert_template 'quality_control'
    end
  end

  context "quality_control action as admin" do
    should "render quality_control template" do
      login_as_admin
      get "quality_control", :publisher_id => "1"
      assert_template 'quality_control'
    end
  end

  context "site_info action as publisher" do
    should "render site_info template" do
      login_as_publisher
      get "site_info"
      assert_template 'site_info'
    end
  end

  context "site_info action as admin" do
    should "render site_info template" do
      login_as_admin
      get "site_info", :publisher_id => "1"
      assert_template 'site_info'
    end
  end

end
