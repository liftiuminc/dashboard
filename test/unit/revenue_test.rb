require 'test_helper'

class RevenueTest < ActiveSupport::TestCase
  should "be valid" do
    assert Revenue.new.valid?
  end
end
