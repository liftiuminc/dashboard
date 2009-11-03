require 'test_helper'

class UserTest < ActiveSupport::TestCase

  should_acts_as_changelogable do
    User.create!(:email => "joe@myemail.com", :publisher_id => 1, :admin => false, :password => "password",
                 :password_confirmation => "password")
  end
end
