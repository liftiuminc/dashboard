require 'test_helper'

class PublisherNetworkLoginTest < ActiveSupport::TestCase

  should_acts_as_changelogable do
    network = Network.find_by_network_name("Tribal Fusion")
    publisher = Publisher.find(:first)
    PublisherNetworkLogin.create!(:network_id => network.id, :publisher_id => publisher.id, :username => "username",
                                  :password => "password")
  end

end
