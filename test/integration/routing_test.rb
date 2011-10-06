require 'test_helper'

class RoutingTest < ActionDispatch::IntegrationTest
  test "visiting /admin redirects to /admin/editions" do
    get "/admin"
    assert_redirected_to "/admin/editions"
  end

  test "visiting / redirects to /topics" do
    get "/"
    assert_redirected_to "/topics"
  end
end
