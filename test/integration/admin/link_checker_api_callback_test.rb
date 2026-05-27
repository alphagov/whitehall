require "test_helper"

class Admin::LinkCheckerApiCallbackTest < ActionDispatch::IntegrationTest
  test "returns 401 (not a redirect) when the signature is invalid" do
    post admin_link_checker_api_callback_path,
         params: { id: 5 }.to_json,
         headers: {
           "Content-Type" => "application/json",
           "X-LinkCheckerApi-Signature" => "invalid",
         }

    assert_response :unauthorized
  end
end
