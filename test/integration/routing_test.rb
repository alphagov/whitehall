require 'test_helper'

class RoutingTest < ActionDispatch::IntegrationTest
  test "visiting #{Whitehall.router_prefix}/admin redirects to /admin/documents" do
    get "#{Whitehall.router_prefix}/admin"
    assert_redirected_to "#{Whitehall.router_prefix}/admin/documents"
  end

  test "visiting / redirects to /topics" do
    get "#{Whitehall.router_prefix}"
    assert_redirected_to "#{Whitehall.router_prefix}/topics"
  end
end
