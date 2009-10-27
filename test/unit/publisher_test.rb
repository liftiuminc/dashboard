require 'test_helper'

class PublisherTest < ActiveSupport::TestCase
  should_have_many :users
  should_have_many :tags
  should_have_many :publisher_network_logins
end
