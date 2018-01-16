require 'test_helper'

class AuthenticationTest < ActionDispatch::IntegrationTest
  setup do
    User.delete_all
    ENV['GDS_SSO_MOCK_INVALID'] = '1'
  end

  test "should use GDS SSO to authenticate" do
    get admin_people_path
    assert_redirected_to "/auth/gds"
  end

  test "should allow access when already logged in" do
    login_as_admin
    get admin_people_path
    assert_response :success
  end

  test "should allow logged in users to log out" do
    login_as_admin
    get admin_people_path
    assert_select "a[href=?]", "/auth/gds/sign_out"
  end

  test "should set the authenticated user header" do
    login_as_admin
    get admin_people_path
    assert_match(
      /uid-\d+/, GdsApi::GovukHeaders.headers[:x_govuk_authenticated_user]
    )
  end
end
