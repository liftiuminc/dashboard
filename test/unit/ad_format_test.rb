require 'test_helper'

class AdFormatTest < ActiveSupport::TestCase
  should_allow_values_for :size, "728x90", "160x600"
  should_not_allow_values_for :size, "adsf", "300x250,300x600"
  should_validate_presence_of :ad_format_name, :size

  should_acts_as_changelogable do
    AdFormat.create!(:ad_format_name => "name", :size => "728x90")
  end
end
