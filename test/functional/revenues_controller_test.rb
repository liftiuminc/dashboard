require 'test_helper'

class RevenuesControllerTest < ActionController::TestCase
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
      get :index, :commit => 1
      assert_template 'index'
    end
  end

  context "index_results action" do
    should "render index_results template" do
      login_as_admin
      get :index_results, :commit => 1
      assert_template 'revenues/_results.html.erb'
    end
  end
  
  context "show action" do
    should "render show template" do
      login_as_admin
      get :show, :id => Revenue.first
      assert_template 'show'
    end
  end
  
  context "new action" do
    should "render new template" do
      login_as_admin
      get :new, :tag_id => 13, :day => '2009-10-10'
      assert_template 'new'
    end
  end
  
  context "discrepancies action" do 
    should "render discrepancies template" do
      login_as_admin
      get :discrepancies
      assert_template 'discrepancies'
    end
  end 

  context "edit action" do
    should "render edit template" do
      login_as_admin
      get :edit, :id => Revenue.first
      assert_template 'edit'
    end
  end
  
 context "update action" do
   should "render edit template when model is invalid" do
     login_as_admin
     Revenue.any_instance.stubs(:valid?).returns(false)
     put :update, :id => Revenue.first
     assert_template 'edit'
   end
 
   should "redirect when model is valid" do
     login_as_admin
     Revenue.any_instance.stubs(:valid?).returns(true)
     put :update, :id => Revenue.first
     assert_redirected_to revenue_url(assigns(:revenue))
   end
 end
 
  context "destroy action" do
    should "destroy model and redirect to index action" do
      login_as_admin
      revenue = Revenue.first
      delete :destroy, :id => revenue
      assert_redirected_to revenues_url
      assert !Revenue.exists?(revenue.id)
    end
  end
end
