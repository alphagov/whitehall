require 'test_helper'

class RoutingTest < ActionDispatch::IntegrationTest
  test "visiting #{Whitehall.router_prefix}/admin redirects to /admin/documents" do
    get "#{Whitehall.router_prefix}/admin"
    assert_redirected_to "#{Whitehall.router_prefix}/admin/documents"
  end

  test "visiting #{Whitehall.router_prefix}/ redirects to #{Whitehall.router_prefix}/topics" do
    get "#{Whitehall.router_prefix}"
    assert_redirected_to "#{Whitehall.router_prefix}/topics"
  end

  test "assets are served under the #{Whitehall.router_prefix} prefix" do
    get topics_path
    assert_select "script[src=?]", "/government/assets/application.js"
  end
end
