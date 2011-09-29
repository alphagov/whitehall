require 'test_helper'

class RoutingTest < ActionDispatch::IntegrationTest
  test "visiting /admin redirects to /admin/editions" do
    get "/admin"
    assert_redirected_to "/admin/editions"
  end
end
