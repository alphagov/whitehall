require "test_helper"

class FlipflopTest < ActionDispatch::IntegrationTest
  teardown do
    ENV.delete("GDS_SSO_MOCK_INVALID")
  end

  test "redirects unauthenticated users to signon" do
    ENV["GDS_SSO_MOCK_INVALID"] = "1"
    get "/flipflop"
    assert_redirected_to "/auth/gds"
  end

  test "allows access when signed in on integration or staging" do
    Whitehall.stubs(:integration_or_staging?).returns(true)
    login_as_admin
    get "/flipflop"
    assert_response :success
  end

  test "forbids access when signed in on production" do
    Whitehall.stubs(:integration_or_staging?).returns(false)
    login_as_admin
    get "/flipflop"
    assert_response :forbidden
  end
end
