require 'test_helper'

class RevenueTest < ActiveSupport::TestCase
    @@day = '2004-01-01'

    should_belong_to :tag
    should_belong_to :user
    
    should "be valid" do
        rev = Revenue.new( :day => @@day, :tag_id => '13', :user_id => '42' )
        assert rev.valid?
    end    
    
    ### %w makes an array, *( ) derefences it again
#     %w( attempts rejects clicks ).each do |f|
#         should_allow_values_for f,      *( %w( 0 1 9999999 ) )
#         should_not_allow_values_for f,  *( %w( -1 1.5 1,24 foo ) )       
#     end        
#     
#     %w( ecpm revenue ).each do |f|
#         should_allow_values_for f,      *( %w( 0 1 1.5 9999999 ) )
#         should_not_allow_values_for f,  *( %w( -1 1,24 foo ) )       
#     end
#     
#     %w( day ).each do |f|
#         should_allow_values_for f,      @@day, "10/01/2009", "1-1-1980"
#         should_not_allow_values_for f,  "foo", "42"
#     end        

    should "Calculate ecpm" do
        rev = Revenue.new :day      => @@day, :clicks   => 1, :revenue => 1, 
                          :tag_id   => "13",  :user_id  => "42"
        assert rev.save
        assert rev.ecpm == 1000  
        assert rev.day.to_s == @@day
        assert rev.destroy
    end
    
    should "Calculate clicks" do
        rev = Revenue.new :day      => @@day, :clicks   => 1, :ecpm => 1000,
                          :tag_id   => "13",  :user_id  => "42"
        assert rev.save
        assert rev.clicks == 1
        assert rev.destroy
    end
    
    
end
