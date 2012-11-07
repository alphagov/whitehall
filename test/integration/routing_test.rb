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

  test "visiting / on frontend redirects to #{Whitehall.router_prefix}" do
    host! 'whitehall-frontend.production.alphagov.co.uk'
    get "/"
    assert_redirected_to "#{Whitehall.router_prefix}/"
  end

  test "visiting / on an admin host redirects to #{Whitehall.router_prefix}/admin" do
    host! 'whitehall-admin.production.alphagov.co.uk'
    get "/"
    assert_redirected_to "#{Whitehall.router_prefix}/admin/"
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
    assert_select "a.open_website[href=?]", "http://www.preview.alphagov.co.uk/government"
  end

  test "admin links to open website points to router website in production" do
    host! 'whitehall.production.alphagov.co.uk'
    login_as_admin
    get_via_redirect admin_root_path
    assert_select "a.open_website[href=?]", "http://www.gov.uk/government"
  end

  test "should redirect from old tour page to mainstream tour page in case the URL has escaped into the wild" do
    get "/government/tour"
    assert_redirected_to "/tour"
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
