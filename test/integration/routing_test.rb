require 'test_helper'

class RoutingTest < ActionDispatch::IntegrationTest
  test "visiting #{Whitehall.router_prefix}/policy-topics redirects to #{Whitehall.router_prefix}/topics" do
    get "#{Whitehall.router_prefix}/policy-topics"
    assert_redirected_to "#{Whitehall.router_prefix}/topics"
  end

  test "visiting #{Whitehall.router_prefix} when not in frontend redirects to /" do
    get "#{Whitehall.router_prefix}"
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

  test "should allow access to admin URLs for non-single-domain requests" do
    login_as_admin
    get_via_redirect "/government/admin"
    assert_response :success
  end

  test "should allow access to non-admin URLs for requests through the single domain router" do
    get_via_redirect "/government/history/king-charles-street", {}, "HTTP_X_GOVUK_ROUTER_REQUEST" => true
    assert_response :success
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

  test "atom feed responds with atom to both /government/feed and /government/feed.atom requests" do
    get "/government/feed"
    assert_equal 200, response.status
    assert_equal Mime::ATOM, response.content_type

    get "/government/feed.atom"
    assert_equal 200, response.status
    assert_equal Mime::ATOM, response.content_type
  end

  test "atom feed returns 404s for other content types" do
    assert_raise ActionController::RoutingError do
      get "/government/feed.json"
    end
  end

  test "routing to editions#show will redirect to correct edition type" do
    login_as_admin
    publication = create(:publication)
    get "/government/admin/editions/#{publication.id}"
    assert_redirected_to "/government/admin/publications/#{publication.id}"
  end
end
