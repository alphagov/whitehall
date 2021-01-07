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

  view_test "GET :new redirects to email-alert-frontend if signup is for a topical event" do
    topical_event = create(:topical_event)
    get :new, params: { email_signup: { feed: atom_feed_url_for(topical_event) } }

    assert_redirected_to "http://test.host/email-signup?link=#{topical_event.base_path}"
  end

  view_test "GET :new redirects to email-alert-frontend if signup is for a world location" do
    world_location = create(:world_location)
    stub_email_alert_api_has_subscriber_list(
      "links" => { "world_locations" => [world_location.content_id] },
      "slug" => "some-slug",
    )

    get :new, params: { email_signup: { feed: atom_feed_url_for(world_location) } }

    assert_redirected_to "https://www.test.gov.uk/email/subscriptions/new?topic_id=some-slug"
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
end
