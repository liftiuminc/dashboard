require 'test_helper'

class JavascriptErrorsControllerTest < ActionController::TestCase
  context "index action" do
    should "render index template" do
      get :index
      assert_template 'index'
    end
  end
  
  context "show action" do
    should "render show template" do
      get :show, :id => JavascriptError.first
      assert_template 'show'
    end
  end
end
