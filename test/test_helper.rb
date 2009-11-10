ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'mocha'
require 'test_help'
# http://rdoc.info/rdoc/binarylogic/authlogic/blob/f2f6988d3b97e11770b00b72a7a9733df69ffa5b/Authlogic/TestCase.html
require "authlogic/test_case"

class ActiveSupport::TestCase
  # Transactional fixtures accelerate your tests by wrapping each test method
  # in a transaction that's rolled back on completion.  This ensures that the
  # test database remains unchanged so your fixtures don't have to be reloaded
  # between every test method.  Fewer database queries means faster tests.
  #
  # Read Mike Clark's excellent walkthrough at
  #   http://clarkware.com/cgi/blosxom/2005/10/24#Rails10FastTesting
  #
  # Every Active Record database supports transactions except MyISAM tables
  # in MySQL.  Turn off transactional fixtures in this case; however, if you
  # don't care one way or the other, switching from MyISAM to InnoDB tables
  # is recommended.
  #
  # The only drawback to using transactional fixtures is when you actually
  # need to test transactions.  Since your test is bracketed by a transaction,
  # any transactions started in your code will be automatically rolled back.
  self.use_transactional_fixtures = true

  # Instantiated fixtures are slow, but give you @david where otherwise you
  # would need people(:david).  If you don't want to migrate your existing
  # test cases which use the @david style and don't mind the speed hit (each
  # instantiated fixtures translates to a database query per test method),
  # then set this back to true.
  self.use_instantiated_fixtures = false

  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all

  # Add more helper methods to be used by all tests here...
  def login_as(user)
    UserSession.create(user)
  end

  def login_as_admin
    login_as(user = User.first(:conditions => ["email = ?", "unit_test_admin@liftium.com"]))
    user
  end

  def login_as_publisher
    login_as(User.first(:conditions => ["email = ?", "unit_test_publisher@liftium.com"]))
  end

  def assert_changes(klass, amount = 1)
    before_count = klass.count
    yield
    assert_equal before_count + amount, klass.count, "Expected #{klass} to be incremented by #{amount} but wasn't"
  end

  def self.should_acts_as_changelogable
    target_klass_string = self.to_s.split("Test").first

    context "acts_as_changelogable" do
      should "add an entry into the acts_as_changelogs table each time a record is created" do
        assert_changes(ActsAsChangelogable::Changelog) do
          yield
        end
        changelog = ActsAsChangelogable::Changelog.find(:first, :order => "created_at DESC")
        assert_equal target_klass_string, changelog.record_type
      end
    end
  end

  @@unique_id = 0
  def login_as_new_user
    ### @@x++ is a syntax error? odd... -Jos
    ### That's because there isn't a ++ operator in Ruby. += is correct. SJT
    @@unique_id += 1

    user = User.create( :email          => "liftium#{@@unique_id}@example.com",
                        :password       => 'password',
                        :publisher_id   => 1 )
    login_as( user )
    return user
  end
end
