require 'test_helper'
require "gds_api/test_helpers/content_store"

class RoutingTest < ActionDispatch::IntegrationTest
  include GdsApi::TestHelpers::ContentStore

  test "visiting #{Whitehall.router_prefix}/policy-topics redirects to #{Whitehall.router_prefix}/topics" do
    get "#{Whitehall.router_prefix}/policy-topics"
    assert_redirected_to "#{Whitehall.router_prefix}/topics"
  end

  test "assets are served under the #{Whitehall.router_prefix} prefix" do
    content_store_has_item('/government/publications', {})

    get publications_path
    assert_select "script[src=?]", "#{Whitehall.router_prefix}/assets/application.js"
  end

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

  test "should redirect from old tour page to mainstream tour page in case the URL has escaped into the wild" do
    get "/government/tour"
    assert_redirected_to "/tour"
  end

  test "admin URLs are reachable when accessed via the admin host in production" do
    admin_host = 'whitehall-admin.production.alphagov.co.uk'
    Whitehall.stubs(:admin_host).returns(admin_host)
    Rails.stubs(:env).returns(ActiveSupport::StringInquirer.new("production"))
    host! admin_host
    login_as_admin

    get "/government/admin"
    assert_response :success
  end

  test "admin URLs are not reachable when accessed via non-admin hosts in production" do
    Whitehall.stubs(:admin_host).returns('whitehall-admin.production.alphagov.co.uk')
    Rails.stubs(:env).returns(ActiveSupport::StringInquirer.new("production"))
    host! 'whitehall.production.alphagov.co.uk'
    login_as_admin

    assert_raise(ActionController::RoutingError) do
      get "/government/admin"
    end
  end

  test "redirects organisation groups index URL to organisation page" do
    organisation = create(:organisation)
    get "/government/organisations/#{organisation.to_param}/groups"
    assert_redirected_to organisation_path(organisation)
  end

  test "redirects organisation groups show URL to organisation page" do
    organisation = create(:organisation)
    get "/government/organisations/#{organisation.to_param}/groups/some-group"
    assert_redirected_to organisation_path(organisation)
  end

  test "redirects organisation chiefs-of-staff URL to organisation page" do
    organisation = create(:organisation)
    get "/government/organisations/#{organisation.to_param}/chiefs-of-staff"
    assert_redirected_to organisation_path(organisation)
  end

  test "redirects organisation consultations URL to organisation page" do
    organisation = create(:organisation)
    get "/government/organisations/#{organisation.to_param}/consultations"
    assert_redirected_to organisation_path(organisation)
  end

  test "redirects organisation series URL to publications page" do
    organisation = create(:organisation)
    get "/government/organisations/#{organisation.to_param}/series"
    assert_redirected_to publications_path
  end

  test "routing to editions#show will redirect to correct edition type" do
    login_as_admin
    publication = create(:publication)
    get "/government/admin/editions/#{publication.id}"
    assert_redirected_to "/government/admin/publications/#{publication.id}"
  end

  test "routing to world location news" do
    create(:world_location, slug: "france", translated_into: [:fr])

    get "/world/france/news.fr"
    assert_response :success
  end
end
