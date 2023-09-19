require "test_helper"

class Admin::ErrorsControllerTest < ActionDispatch::IntegrationTest
  setup do
    login_as_admin
  end

  test "should show the bad request page" do
    get "/400"
    assert_template :bad_request
  end

  test "should show the forbidden page" do
    get "/403"
    assert_template :forbidden
  end

  test "should show the not found page" do
    get "/404"
    assert_template :not_found
  end

  test "should show the unprocessable entity page" do
    get "/422"
    assert_template :unprocessable_entity
  end

  test "should show the internal server error page" do
    get "/500"
    assert_template :internal_server_error
  end
end
