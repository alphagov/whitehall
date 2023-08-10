require "test_helper"
require "gds_api/test_helpers/content_store"

class RoutingTest < ActionDispatch::IntegrationTest
  include GdsApi::TestHelpers::ContentStore
  include TaxonomyHelper

  test "visiting #{Whitehall.router_prefix} when not in frontend redirects to /" do
    get Whitehall.router_prefix
    assert_redirected_to "/"
  end

  test "visiting / on the admin host redirects to #{Whitehall.router_prefix}/admin" do
    host! Whitehall.admin_host
    get "/"
    assert_redirected_to "#{Whitehall.router_prefix}/admin/"
  end

  test "visiting unknown route should respond with 404 not found" do
    assert_raise(ActionController::RoutingError) do
      get "/government/path-unknown-to-application"
    end
  end

  test "admin URLs are reachable when accessed via the admin host in production" do
    admin_host = "whitehall-admin.production.alphagov.co.uk"
    Whitehall.stubs(:admin_host).returns(admin_host)
    Rails.stubs(:env).returns(ActiveSupport::StringInquirer.new("production"))
    host! admin_host
    login_as_admin

    get "/government/admin"
    assert_response :success
  end

  test "admin URLs are not reachable when accessed via non-admin hosts in production" do
    Whitehall.stubs(:admin_host).returns("whitehall-admin.production.alphagov.co.uk")
    Rails.stubs(:env).returns(ActiveSupport::StringInquirer.new("production"))
    host! "whitehall.production.alphagov.co.uk"
    login_as_admin

    assert_raise(ActionController::RoutingError) do
      get "/government/admin"
    end
  end

  test "routing to editions#show will redirect to correct edition type" do
    login_as_admin
    publication = create(:publication)
    get "/government/admin/editions/#{publication.id}"
    assert_redirected_to "/government/admin/publications/#{publication.id}"
  end
end
