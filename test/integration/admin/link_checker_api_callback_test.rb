require "test_helper"

class Admin::LinkCheckerApiCallbackTest < ActionDispatch::IntegrationTest
  test "returns 400 when the signature does not match the body" do
    post admin_link_checker_api_callback_path,
         params: { id: 5 }.to_json,
         headers: {
           "Content-Type" => "application/json",
           "X-LinkCheckerApi-Signature" => "invalid",
         }

    assert_response :bad_request
  end
end
