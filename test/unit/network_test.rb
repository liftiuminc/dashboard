require 'test_helper'

class NetworkTest < ActiveSupport::TestCase

  setup do
    ChangelogSession.begin
  end

  teardown do
    ChangelogSession.end
  end

  should_acts_as_changelogable do
    Network.create!(
        ### use this network
        :network_name           => "name", 
        :website                => "www.something.url", 
        :pay_type               => Network::ALL_PAY_TYPES.first,
        :enabled                => true, 
        :supports_threshold     => true, 
        :default_always_fill    => true, 
        :us_only                => true,
        :comments               => "comments"
    )
  end

  should "have a network configuration" do
    obj = Network.first( :conditions => { :network_name => "Test" } )

    assert obj
    assert obj.network_config
    assert !obj.network_config.empty?    
  end    
end
