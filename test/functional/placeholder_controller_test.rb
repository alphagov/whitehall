require 'test_helper'

class PlaceholderControllerTest < ActionController::TestCase
  should_be_a_public_facing_controller

  test "should get show" do
    get :show
    assert_response :success
  end
end
