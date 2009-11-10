require 'test_helper'

class NetworkTest < ActiveSupport::TestCase

  setup do
    ActsAsChangelogable::Session.begin
  end

  teardown do
    ActsAsChangelogable::Session.end
  end

  should_acts_as_changelogable do
    Network.create!(:network_name => "name", :website => "www.something.url", :pay_type => Network::ALL_PAY_TYPES.first,
                    :enabled => true, :supports_threshold => true, :default_always_fill => true, :us_only => true,
                    :comments => "comments")
  end
end
