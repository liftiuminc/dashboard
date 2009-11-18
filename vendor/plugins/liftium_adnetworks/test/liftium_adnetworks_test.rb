require 'test/unit'
require 'liftium_adnetworks'

class LiftiumAdnetworksTest < Test::Unit::TestCase 

  ### list of networks picked from production
  @@networks = [ 
    "Ad.com",
    "AdBrite",
    "ContextWeb",
    "Game Advertising Online",
    "Google AdSense",
    "Test",
#     "Test (US only)",          
#     "Tribal Fusion", 
  ]

  def test_must_turn_into_object
    @@networks.each do |n|
      obj = Liftium::AdNetworks.new_from_name( n )
      puts obj

      assert obj

    end  
  end
end    
  
