require 'test_helper'

class UserTest < ActiveSupport::TestCase

  context "required password" do
    should "be valid if both the password and password confirmation are provided and match" do
      user = User.new(:email => "joe@myemail.com", :publisher_id => 1, :admin => false, :password => "password",
                      :password_confirmation => "password")
      assert user.valid?
    end

    should "not be valid if the password and password_confirmation are not provided and the user doesn't have a crypted_password (new_record)" do
      user = User.new(:email => "joe@myemail.com", :publisher_id => 1, :admin => false, :password => "",
                      :password_confirmation => "")
      assert !user.valid?
      assert_equal ["is too short (minimum is 4 characters)", "doesn't match confirmation", "can't be blank"],
                   user.errors.on(:password)
    end

    should "not be valid if the password and password_confirmation do not match" do
      user = User.new(:email => "joe@myemail.com", :publisher_id => 1, :admin => false, :password => "password",
                      :password_confirmation => "")
      assert !user.valid?
      assert_equal "doesn't match confirmation", user.errors.on(:password)
    end

    should "not check the password and password_confirmation fields if the user has a crypted_password and both fields are empty" do
      user = User.find(49)
      crypted_password = user.crypted_password
      assert user.update_attributes(:admin => 0)
      assert user.update_attributes(:admin => 0, :password => "", :password_confirmation => "")
      assert_equal crypted_password, user.reload.crypted_password
    end
  end

end
