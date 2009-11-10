require 'test_helper'

class RevenuesControllerTest < ActionController::TestCase
  setup :activate_authlogic

  setup do
    ActsAsChangelogable::Session.begin
  end

  teardown do
    ActsAsChangelogable::Session.end
  end
  
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

# FIXME -- these tests won't work without a 'tag' being provided
#  context "create action" do
#    should "render new template when model is invalid" do
#      login_as_admin
#      Revenue.any_instance.stubs(:valid?).returns(false)
#      post :create
#      assert_template 'new'
#    end
#
#    should "redirect when model is valid" do
#      login_as_admin
#      Revenue.any_instance.stubs(:valid?).returns(true)
#      post :create
#      assert_redirected_to revenue_url(assigns(:revenue))
#    end
# end

  context "edit action" do
    should "render edit template" do
      login_as_admin
      get :edit, :id => Revenue.first
      assert_template 'edit'
    end
  end

#FIXME
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
