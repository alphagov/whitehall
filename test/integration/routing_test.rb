require 'test_helper'

class RoutingTest < ActionDispatch::IntegrationTest
  test "visiting #{Whitehall.router_prefix}/admin redirects to /admin/documents" do
    get "#{Whitehall.router_prefix}/admin"
    assert_redirected_to "#{Whitehall.router_prefix}/admin/documents"
  end

  test "visiting #{Whitehall.router_prefix}/topics redirects to #{Whitehall.router_prefix}/policy-topics" do
    get "#{Whitehall.router_prefix}/topics"
    assert_redirected_to "#{Whitehall.router_prefix}/policy-topics"
  end

  test "assets are served under the #{Whitehall.router_prefix} prefix" do
    get policy_topics_path
    assert_select "script[src=?]", "/government/assets/application.js"
  end

  test "visiting / redirects to #{Whitehall.router_prefix}" do
    get "/"
    assert_redirected_to "#{Whitehall.router_prefix}/"
  end

  test "visiting unknown route should respond with 404 not found" do
    assert_raises(ActionController::RoutingError) do
      get "/government/path-unknown-to-application"
    end
  end

  test "should allow access to admin URLs for non-single-domain requests" do
    login_as_admin
    get_via_redirect "/government/admin"
    assert_response :success
  end

  test "should allow access to non-admin URLs for requests through the single domain router" do
    get_via_redirect "/government", {}, "HTTP_X_GOVUK_ROUTER_REQUEST" => true
    assert_response :success
  end

  test "should block access to admin URLs for requests through the single domain router" do
    assert_raises(ActionController::RoutingError) do
      get "/government/admin", {}, "HTTP_X_GOVUK_ROUTER_REQUEST" => true
    end
  end

  test "should block access to admin URLs for requests through the single domain host" do
    assert_raises(ActionController::RoutingError) do
      host! 'www.gov.uk'
      get "/government/admin"
    end
  end

  test "admin links to open website points to router website in preview" do
    host! 'whitehall.preview.alphagov.co.uk'
    login_as_admin
    get_via_redirect admin_root_path
    assert_select "a.open_website[href=?]", "http://www.preview.alphagov.co.uk/government/home"
  end

  test "admin links to open website points to router website in production" do
    host! 'whitehall.production.alphagov.co.uk'
    login_as_admin
    get_via_redirect admin_root_path
    assert_select "a.open_website[href=?]", "http://www.gov.uk/government/home"
  end

  test "should link to whitehall tour from home page" do
    get_via_redirect "/government/home"
    assert_select "a[href=?]", tour_path
  end

  test "should route to whitehall tour page" do
    get_via_redirect tour_path
    assert_response :success
  end

  test "whitehall tour page links to generic feedback link" do
    get_via_redirect tour_path
    assert_select "a[href=?]", "/feedback"
  end
end
