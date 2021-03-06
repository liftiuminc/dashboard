require 'test_helper'

class PublisherTest < ActiveSupport::TestCase
  should_have_many :users
  should_have_many :tags
  should_have_many :publisher_network_logins

  should_acts_as_changelogable do
    Publisher.create!(
        :site_name          => "name", 
        :site_url           => "www.something.url", 
        :brand_safety_level => 1, 
        :hoptime            => 1
    )
  end

  should "find publisher" do
    obj = Publisher.find_by_id( 1 )
    
    assert obj
    assert obj.active_networks
    
  end

end
