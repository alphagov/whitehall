require 'test_helper'

class RoutingTest < ActionDispatch::IntegrationTest
  test "visiting #{Whitehall.router_prefix}/admin redirects to /admin/editions" do
    get "#{Whitehall.router_prefix}/admin"
    assert_redirected_to "#{Whitehall.router_prefix}/admin/editions"
  end

  test "visiting #{Whitehall.router_prefix}/policy-topics redirects to #{Whitehall.router_prefix}/topics" do
    get "#{Whitehall.router_prefix}/policy-topics"
    assert_redirected_to "#{Whitehall.router_prefix}/topics"
  end

  test "assets are served under the #{Whitehall.router_prefix} prefix" do
    get topics_path
    assert_select "script[src=?]", "#{Whitehall.router_prefix}/assets/application.js"
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

  test "admin is unreachable in preview from whitehall" do
    host! 'whitehall.preview.alphagov.co.uk'
    Rails.stubs(:env).returns(ActiveSupport::StringInquirer.new("production"))
    assert_raises(ActionController::RoutingError) do
      get "/government/admin"
    end
  end

  test "admin is reachable in preview from whitehall-admin" do
    host! 'whitehall-admin.preview.alphagov.co.uk'
    Rails.stubs(:env).returns(ActiveSupport::StringInquirer.new("production"))
    get "/government/admin"
    assert_redirected_to "/government/admin/editions"
  end

  test "admin is unreachable in production from whitehall" do
    host! 'whitehall.production.alphagov.co.uk'
    Rails.stubs(:env).returns(ActiveSupport::StringInquirer.new("production"))
    assert_raises(ActionController::RoutingError) do
      get "/government/admin"
    end
  end

  test "admin is reachable in production from whitehall-admin" do
    host! 'whitehall-admin.production.alphagov.co.uk'
    Rails.stubs(:env).returns(ActiveSupport::StringInquirer.new("production"))
    get "/government/admin"
    assert_redirected_to "/government/admin/editions"
  end

  test "visiting a detailed guidance document redirects you to the slug at root" do
    get "/specialist/vat-tax-rates"
    assert_redirected_to "/vat-tax-rates"
  end
end
