require "test_helper"

class ComponentGuideTest < ActionDispatch::IntegrationTest
  test "redirects unauthenticated users to signon" do
    ENV["GDS_SSO_MOCK_INVALID"] = "1"
    get "/component-guide"
    assert_redirected_to "/auth/gds"
  end

  test "allows access when signed in" do
    login_as_admin
    get "/component-guide"
    assert_response :success
  end
end
