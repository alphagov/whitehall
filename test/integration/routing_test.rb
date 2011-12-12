require 'test_helper'

class RoutingTest < ActionDispatch::IntegrationTest
  test "visiting #{Whitehall.router_prefix}/admin redirects to /admin/documents" do
    get "#{Whitehall.router_prefix}/admin"
    assert_redirected_to "#{Whitehall.router_prefix}/admin/documents"
  end

  test "visiting #{Whitehall.router_prefix}/ redirects to #{Whitehall.router_prefix}/policy-areas" do
    get "#{Whitehall.router_prefix}"
    assert_redirected_to "#{Whitehall.router_prefix}/policy-areas"
  end

  test "visiting #{Whitehall.router_prefix}/topics redirects to #{Whitehall.router_prefix}/policy-areas" do
    get "#{Whitehall.router_prefix}/topics"
    assert_redirected_to "#{Whitehall.router_prefix}/policy-areas"
  end

  test "assets are served under the #{Whitehall.router_prefix} prefix" do
    get policy_areas_path
    assert_select "script[src=?]", "/government/assets/application.js"
  end

  test "visiting / redirects to #{Whitehall.router_prefix}" do
    get "/"
    assert_redirected_to "#{Whitehall.router_prefix}/"
  end

  test "visiting unknown route should respond with 404 not found" do
    get "/government/path-unknown-to-application"
    assert_response :not_found
  end

  test "should allow access to admin URLs for non-single-domain requests" do
    get_via_redirect "/government/admin"
    assert_response :success
  end

  test "should allow access to login path from non-single-domain requests" do
    get_via_redirect login_path
    assert_response :success
  end

  test "should allow access to logout path from non-single-domain requests" do
    post_via_redirect logout_path
    assert_response :success
  end

  test "should allow access to create session path from non-single-domain requests" do
    post_via_redirect session_path
    assert_response :success
  end

  test "should allow access to destroy session path from non-single-domain requests" do
    delete_via_redirect session_path
    assert_response :success
  end

  test "should allow access to non-admin URLs for requests through the single domain router" do
    get_via_redirect "/government", {}, "HTTP_X_GOVUK_ROUTER_REQUEST" => true
    assert_response :success
  end

  test "should block access to admin URLs for requests through the single domain router" do
    get_via_redirect "/government/admin", {}, "HTTP_X_GOVUK_ROUTER_REQUEST" => true
    assert_response :not_found
  end

  test "should block access to login path for requests through the single domain router" do
    get_via_redirect login_path, {}, "HTTP_X_GOVUK_ROUTER_REQUEST" => true
    assert_response :not_found
  end

  test "should block access to logout path for requests through the single domain router" do
    post_via_redirect logout_path, {}, "HTTP_X_GOVUK_ROUTER_REQUEST" => true
    assert_response :not_found
  end

  test "should block access to create session path for requests through the single domain router" do
    post_via_redirect session_path, {}, "HTTP_X_GOVUK_ROUTER_REQUEST" => true
    assert_response :not_found
  end

  test "should block access to destroy session path for requests through the single domain router" do
    delete_via_redirect session_path, {}, "HTTP_X_GOVUK_ROUTER_REQUEST" => true
    assert_response :not_found
  end
end
