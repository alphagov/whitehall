require 'test_helper'

class RoutingTest < ActionDispatch::IntegrationTest
  test "visiting /admin redirects to /admin/documents" do
    get "/admin"
    assert_redirected_to "/admin/documents"
  end

  test "visiting / redirects to /topics" do
    get "/"
    assert_redirected_to "/topics"
  end
end
