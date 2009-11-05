require 'test_helper'

class MoversControllerTest < ActionController::TestCase
  setup :activate_authlogic
 
  DateRangeHelper.timeframes.each do |timeframe|
    context "index action" do
      should "render for '#{timeframe}'" do
        login_as_admin
        get :index, params = { :date_select => timeframe }
        assert_response :success
        assert_template :index
      end
    end
  end
end
