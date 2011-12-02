require 'test_helper'

class RoutingTest < ActionDispatch::IntegrationTest
  test "visiting #{Whitehall.router_prefix}/admin redirects to /admin/documents" do
    get "#{Whitehall.router_prefix}/admin"
    assert_redirected_to "#{Whitehall.router_prefix}/admin/documents"
  end

  test "visiting #{Whitehall.router_prefix}/ redirects to #{Whitehall.router_prefix}/policy_areas" do
    get "#{Whitehall.router_prefix}"
    assert_redirected_to "#{Whitehall.router_prefix}/policy_areas"
  end

  test "assets are served under the #{Whitehall.router_prefix} prefix" do
    get policy_areas_path
    assert_select "script[src=?]", "/government/assets/application.js"
  end

  test "visiting / redirects to #{Whitehall.router_prefix}" do
    get "/"
    assert_redirected_to "#{Whitehall.router_prefix}/"
  end
end
