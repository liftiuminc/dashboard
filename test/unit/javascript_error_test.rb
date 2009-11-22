require 'test_helper'

class JavascriptErrorTest < ActiveSupport::TestCase
  should "be valid" do
    assert JavascriptError.new.valid?
  end
end
