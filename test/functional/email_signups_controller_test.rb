require "test_helper"
require "gds_api/test_helpers/email_alert_api"

class EmailSignupsControllerTest < ActionController::TestCase
  include FeedHelper
  include GdsApi::TestHelpers::EmailAlertApi

  view_test "GET :new redirects to email-alert-frontend if signup is for a organisation" do
    organisation = create(:organisation)
    get :new, params: { email_signup: { feed: atom_feed_url_for(organisation) } }

    assert_redirected_to "http://test.host/email-signup?link=#{organisation.base_path}"
  end

  view_test "GET :new redirects to email-alert-frontend if signup is for a ministerial role" do
    ministerial_role = create(:ministerial_role)
    get :new, params: { email_signup: { feed: atom_feed_url_for(ministerial_role) } }

    assert_redirected_to "http://test.host/email-signup?link=/government/ministers/#{ministerial_role.slug}"
  end

  view_test "GET :new redirects to email-alert-frontend if signup is for a topical event" do
    topical_event = create(:topical_event)
    get :new, params: { email_signup: { feed: atom_feed_url_for(topical_event) } }

    assert_redirected_to "http://test.host/email-signup?link=#{topical_event.base_path}"
  end

  view_test "GET :new renders a whitehall email signup page for a world location" do
    world_location = create(:world_location)
    get :new, params: { email_signup: { feed: atom_feed_url_for(world_location) } }

    assert_select "h1", "Email alert subscription"
    assert_select "p", "You're signing up to all alerts for #{world_location.name}"
  end

  view_test "GET :new redirects to publications controller if signup is for a publication finder" do
    feed = "http://test.host/government/publications.atom?departments%5B%5D=org1&departments%5B%5D=org2&publication_filter_option=open-consultations"
    get :new, params: { email_signup: { feed: feed } }

    assert_redirected_to publications_path(publication_filter_option: "open-consultations", departments: %w[org1 org2])
  end

  view_test "GET :new redirects to statistics controller if signup is for a statistics finder" do
    feed = "http://test.host/government/statistics.atom?departments%5B%5D=org1&departments%5B%5D=org2"
    get :new, params: { email_signup: { feed: feed } }

    assert_redirected_to statistics_path(departments: %w[org1 org2])
  end

  view_test "GET :new redirects to announcements controller if signup is for an announcement finder" do
    feed = "http://test.host/government/announcements.atom?departments%5B%5D=org1&departments%5B%5D=org2"
    get :new, params: { email_signup: { feed: feed } }

    assert_redirected_to announcements_path(departments: %w[org1 org2])
  end

  view_test "GET :new with an invalid feed redirects to the home page" do
    get :new, params: { email_signup: { feed: "http://nonse-feed.atom" } }

    assert_redirected_to "http://test.host/"
  end

  view_test "POST :create with a valid email signup redirects to the signup URL" do
    world_location = create(:world_location)
    email_alert_api_has_subscriber_list(
      "links" => { "world_locations" => [world_location.content_id] },
      "subscription_url" => "http://email_alert_api_signup_url",
    )

    post :create, params: { email_signup: { feed: atom_feed_url_for(world_location) } }
    assert_response :redirect
    assert_redirected_to "http://email_alert_api_signup_url"
  end

  view_test "POST :create with a invalid email signup renders the new view" do
    topical_event = create(:topical_event)
    email_alert_api_has_subscriber_list(
      "links" => { "topical_event" => [topical_event.content_id] },
      "subscription_url" => "http://email_alert_api_signup_url",
    )

    post :create, params: { email_signup: { feed: atom_feed_url_for(topical_event) } }
    assert_select "p", "Sorry, we could not find a valid email alerts feed for that."
  end
end
