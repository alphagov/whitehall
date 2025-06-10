require "test_helper"

class Admin::FlexiblePagesControllerTest < ActionController::TestCase
  should_be_an_admin_controller

  setup do
    login_as :writer
  end

  test "GET new returns a not found response when the flexible pages feature flag is disabled" do
    get :new
    assert_response :not_found
  end
end
