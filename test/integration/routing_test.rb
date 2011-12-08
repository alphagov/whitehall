require 'test_helper'

class RoutingTest < ActionDispatch::IntegrationTest

  SINGLE_DOMAIN_HOSTS = [
    "www.preview.alphagov.co.uk",
    "preview.alphagov.co.uk",
    "www.production.alphagov.co.uk",
    "production.alphagov.co.uk"
  ]

  NON_SINGLE_DOMAIN_HOSTS = [
    "whitehall.preview.alphagov.co.uk",
    "whitehall.production.alphagov.co.uk"
  ]

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

  NON_SINGLE_DOMAIN_HOSTS.each do |host|
    test "should allow access to non-admin URLs from non-single-domain host: #{host}" do
      host! host
      get_via_redirect "/government"
      assert_response :success
    end

    test "should allow access to admin from non-single-domain host: #{host}" do
      host! host
      get_via_redirect "/government/admin"
      assert_response :success
    end
  end

  SINGLE_DOMAIN_HOSTS.each do |host|
    test "should allow access to non-admin URLs from single-domain host: #{host}" do
      host! host
      get_via_redirect "/government"
      assert_response :success
    end

    test "should not allow access to admin from single-domain host: #{host}" do
      host! host
      get_via_redirect "/government/admin"
      assert_response :not_found
    end
  end
end
