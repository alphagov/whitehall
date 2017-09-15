require 'test_helper'
require 'gds_api/test_helpers/email_alert_api'

class EmailSignupTest < ActiveSupport::TestCase
  include GdsApi::TestHelpers::EmailAlertApi

  test "#save ensures that a relevant topic exists in GovDelivery using the feed and the signup description" do
    email_signup = EmailSignup.new(feed: feed_url)
    response = { "gov_delivery_id" => "TOPIC-123", "subscription_url" => "http://example.com" }

    email_alert_api_does_not_have_subscriber_list("email_document_supertype" => "publications")
    email_alert_api_creates_subscriber_list(response).with do |request|
      assert_equal "publications", JSON.parse(request.body)["title"]
    end

    assert email_signup.save

    assert_equal "TOPIC-123", email_signup.topic_id
    assert_equal "http://example.com", email_signup.govdelivery_url
  end

  test "#save doesn't create a GovDelivery topic if one already exists" do
    email_signup = EmailSignup.new(feed: feed_url)
    email_alert_api_has_subscriber_list("email_document_supertype" => "publications")

    assert email_signup.save
    assert_not_requested(email_alert_api_creates_subscriber_list({}))
  end

  test "#save does not create a GovDelivery topic if the feed is missing" do
    refute EmailSignup.new.save
    assert_not_requested(stub_any_email_alert_api_call)
  end

  test "#save does not create a GovDelivery topic if the feed is invalid" do
    refute EmailSignup.new(feed: 'http://fake/feed').save
    assert_not_requested(stub_any_email_alert_api_call)
  end

  test "#description provides a human-readable description of the filters being applied" do
    feed_url = feed_url("publications.atom?official_document_status=command_and_act_papers")

    expected = "publications which are command or act papers"
    assert_equal expected, EmailSignup.new(feed: feed_url).description
  end

  def feed_url(feed_path = "publications.atom")
    "#{Whitehall.public_protocol}://#{Whitehall.public_host}/government/#{feed_path}"
  end

  def email_signup(feed_path)
    EmailSignup.new(feed: feed_url(feed_path))
  end
end
