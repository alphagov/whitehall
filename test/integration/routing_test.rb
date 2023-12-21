require "test_helper"
require "gds_api/test_helpers/content_store"

class RoutingTest < ActionDispatch::IntegrationTest
  include GdsApi::TestHelpers::ContentStore
  include TaxonomyHelper

  test "visiting #{Whitehall.router_prefix} redirects to /" do
    get Whitehall.router_prefix
    assert_redirected_to "/"
  end

  test "visiting / redirects to #{Whitehall.router_prefix}/admin" do
    host! Whitehall.admin_host
    get "/"
    assert_redirected_to "#{Whitehall.router_prefix}/admin/"
  end

  test "visiting unknown route should respond with 404 not found" do
    assert_raise(ActionController::RoutingError) do
      get "/government/path-unknown-to-application"
    end
  end

  test "routing to editions#show will redirect to correct edition type" do
    login_as_admin
    publication = create(:publication)
    get "/government/admin/editions/#{publication.id}"
    assert_redirected_to "/government/admin/publications/#{publication.id}"
  end
end
