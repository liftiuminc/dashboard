require 'test_helper'
require 'pp'

class RevenueTest < ActiveSupport::TestCase
    should_belong_to :tag
    should_belong_to :user

    should "be valid" do
        assert Revenue.new( :day => "2004-01-01", :tag => "1" ).valid?
    end
    
    ### %w makes an array, *( ) derefences it again
    %w( attempts rejects clicks ).each do |f|
        should_allow_values_for f,      *( %w( 0 1 9999999 ) )
        should_not_allow_values_for f,  *( %w( -1 1.5 1,24 foo ) )       
    end        
    
    %w( ecpm revenue ).each do |f|
        should_allow_values_for f,      *( %w( 0 1 1.5 9999999 ) )
        should_not_allow_values_for f,  *( %w( -1 1,24 foo ) )       
    end
    
    %w( day ).each do |f|
        should_allow_values_for f,      "2004-01-01", "10/01/2009", "1-1-1980"
        should_not_allow_values_for f,  "foo", "42"
    end        
    
end
