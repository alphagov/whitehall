require 'test_helper'

class RoutingTest < ActionDispatch::IntegrationTest
  test "visiting #{Whitehall.router_prefix}/policy-topics redirects to #{Whitehall.router_prefix}/topics" do
    get "#{Whitehall.router_prefix}/policy-topics"
    assert_redirected_to "#{Whitehall.router_prefix}/topics"
  end

  test "assets are served under the #{Whitehall.router_prefix} prefix" do
    get topics_path
    assert_select "script[src=?]", "#{Whitehall.router_prefix}/assets/application.js"
  end

  test "visiting #{Whitehall.router_prefix} on frontend redirects to /" do
    host! 'whitehall-frontend.production.alphagov.co.uk'
    get "#{Whitehall.router_prefix}"
    assert_redirected_to "/"
  end

  test "visiting / on an admin host redirects to #{Whitehall.router_prefix}/admin" do
    host! 'whitehall-admin.production.alphagov.co.uk'
    get "/"
    assert_redirected_to "#{Whitehall.router_prefix}/admin/"
  end

  test "visiting unknown route should respond with 404 not found" do
    assert_raises(ActionController::RoutingError) do
      get "/government/path-unknown-to-application"
    end
  end

  test "should allow access to admin URLs for non-single-domain requests" do
    login_as_admin
    get_via_redirect "/government/admin"
    assert_response :success
  end

  test "should allow access to non-admin URLs for requests through the single domain router" do
    get_via_redirect "/government/how-government-works", {}, "HTTP_X_GOVUK_ROUTER_REQUEST" => true
    assert_response :success
  end

  test "admin links to open website points to router website in preview" do
    host! 'whitehall.preview.alphagov.co.uk'
    login_as_admin
    get_via_redirect admin_root_path
    assert_select "a.open_website[href=?]", "http://www.preview.alphagov.co.uk/government"
  end

  test "admin links to open website points to router website in production" do
    host! 'whitehall.production.alphagov.co.uk'
    login_as_admin
    get_via_redirect admin_root_path
    assert_select "a.open_website[href=?]", "http://www.gov.uk/government"
  end

  test "should redirect from old tour page to mainstream tour page in case the URL has escaped into the wild" do
    get "/government/tour"
    assert_redirected_to "/tour"
  end

  test "admin is unreachable in preview from whitehall" do
    host! 'whitehall.preview.alphagov.co.uk'
    Rails.stubs(:env).returns(ActiveSupport::StringInquirer.new("production"))
    assert_raises(ActionController::RoutingError) do
      get "/government/admin"
    end
  end

  test "admin is reachable in preview from whitehall-admin" do
    login_as_admin
    host! 'whitehall-admin.preview.alphagov.co.uk'
    Rails.stubs(:env).returns(ActiveSupport::StringInquirer.new("production"))
    get "/government/admin"
    assert_response :success
  end

  test "admin is unreachable in production from whitehall" do
    host! 'whitehall.production.alphagov.co.uk'
    Rails.stubs(:env).returns(ActiveSupport::StringInquirer.new("production"))
    assert_raises(ActionController::RoutingError) do
      get "/government/admin"
    end
  end

  test "admin is reachable in production from whitehall-admin" do
    login_as_admin
    host! 'whitehall-admin.production.alphagov.co.uk'
    Rails.stubs(:env).returns(ActiveSupport::StringInquirer.new("production"))
    get "/government/admin"
    assert_response :success
  end

  test "visiting a detailed guidance document redirects you to the slug at root" do
    get "/specialist/vat-tax-rates"
    assert_redirected_to "/vat-tax-rates"
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
    assert_raises ActionController::RoutingError do
      get "/government/feed.json"
    end
  end

  test "routing to editions#show will redirect to correct edition type" do
    login_as_admin
    publication = create(:publication)
    get "/government/admin/editions/#{publication.id}"
    assert_redirected_to "/government/admin/publications/#{publication.id}"
  end

  test "cannot get supporting_pages#show through a non-numerical id" do
    login_as_admin
    edition = create(:draft_policy)
    supporting_page = create(:supporting_page, edition: edition)

    assert_raises ActionController::RoutingError do
      get "/government/admin/editions/#{edition.id}/supporting-pages/#{supporting_page.slug}"
    end
  end

end
