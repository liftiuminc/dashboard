require 'test_helper'

# TODO: Test for new users self-creating accounts

class UsersControllerTest < ActionController::TestCase
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

  ### check permissions on protected controller actions
  %w( new index create ).each do |action|
    context "Action #{action} requires admin rights" do
      should "render 403" do
        login_as_publisher
        get action
        assert_template "public/403.html"
        respond_with 403
      end
    end
  end

  ### check that all other actions are available to users
  ### grab a new user, as destroy is destructive
  %w( show edit update destroy ).each do |action|
    context "Action #{action} should be available to all users" do
      should "Render template" do
        login_as_new_user
        get action
        respond_with 200
      end
    end
  end

  context "show action" do
    should "render show template" do
      login_as_admin
      get :show, :id => User.first
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
      User.any_instance.stubs(:valid?).returns(false)
      post :create
      assert_template 'new'
    end

    should "redirect when model is valid" do
      login_as_admin
      User.any_instance.stubs(:valid?).returns(true)
      post :create
      assert_redirected_to user_url(assigns(:user))
    end
  end

  context "edit action" do
    should "render edit template" do
      login_as_admin
      get :edit, :id => User.first
      assert_template 'edit'
    end
  end

  context "update action" do
    should "render edit template when model is invalid" do
      login_as_admin
      User.any_instance.stubs(:valid?).returns(false)
      put :update, :id => User.first
      assert_template 'edit'
    end

    should "redirect to user list when model is valid" do
      login_as_admin
      User.any_instance.stubs(:valid?).returns(true)
      put :update, :id => User.first
      assert_redirected_to users_path
    end
  end

  context "destroy action" do
    should "destroy model and redirect to index action" do
      login_as_admin
      user = User.first
      delete :destroy, :id => user
      assert_redirected_to users_path
      assert !User.exists?(user.id)
    end
  end

  context "new_change_password" do
    context "Not logged in" do
      should_redirect_to "login url" do
        get :new_change_password
        new_user_session_url
      end
    end

    should "render the new_change_password template" do
      nick = User.find(42)
      login_as(nick)

      get :new_change_password
      assert_response :success
      assert_template :new_change_password
    end
  end

  context "change_password" do
    context "Not logged in" do
      should_redirect_to "login url" do
        post :change_password
        new_user_session_url
      end
    end

    context "with publisher login" do
      setup do
        @publisher = User.find(49)
        login_as(@publisher)
      end

      should "change the users password if the old password, password and password_confirmation are correct" do
        original_crypted_password = @publisher.crypted_password

        post :change_password, :id => @publisher.id, :old_password => "password",
             :user => {:password => "test", :password_confirmation => "test"}
        assert_equal "Your password has been successfully changed.", flash[:notice]
        assert_redirected_to user_path(@publisher)
        assert_not_equal original_crypted_password, @publisher.reload.crypted_password
      end

      should "not change the users password if the old password supplied is not correct" do
        post :change_password, :id => @publisher.id, :old_password => "wrong",
             :user => {:password => "test", :password_confirmation => "test"}
        assert_equal "Your current password was not correct.", flash[:error]
        assert_template :new_change_password
      end

      should "not change the users password if the new passwords do not match" do
        post :change_password, :id => @publisher.id, :old_password => "password",
             :user => {:password => "foo", :password_confirmation => "bar"}
        assert_equal "Your new passwords did not match.", flash[:error]
        assert_template :new_change_password
      end

      should "not change the users password if the new passwords are not supplied" do
        post :change_password, :id => @publisher.id, :old_password => "password",
             :user => {:password => "", :password_confirmation => ""}
        assert_equal "Your new passwords did not match.", flash[:error]
        assert_template :new_change_password
      end
    end
  end
end
