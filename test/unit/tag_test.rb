require 'test_helper'

class TagTest < ActiveSupport::TestCase
  should_allow_values_for :size, "728x90", "160x600"
  should_not_allow_values_for :size, "adsf", "300x250,300x600"
  should_validate_presence_of :tag_name, :network, :size, :publisher

  should_acts_as_changelogable do
    Tag.create!("sample_rate"=>"", "size"=>"728x90", "network_id"=>"2", "tag"=>"", "frequency_cap"=>"",
                "tier"=>"10", "rejection_time"=>"", "enabled"=>"true", "value"=>"1.00", "tag_name"=>"Scotts New Tag",
                "always_fill"=>"false", "publisher_id"=>"1045")
  end
end
