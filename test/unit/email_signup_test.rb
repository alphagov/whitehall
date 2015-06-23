require 'test_helper'

class EmailSignupTest < ActiveSupport::TestCase
  test "#save ensures that a relevant policy area exists in GovDelivery using the feed and the signup description" do
    email_signup = EmailSignup.new(feed: feed_url)

    Whitehall.govuk_delivery_client.expects(:topic).with(feed_url, email_signup.description)

    assert email_signup.save
  end

  test "#save does not create a GovDelivery topic if the feed is missing" do
    Whitehall.govuk_delivery_client.expects(:topic).never

    refute EmailSignup.new.save
  end

  test "#save does not create a GovDelivery topic if the feed is invalid" do
    Whitehall.govuk_delivery_client.expects(:topic).never

    refute EmailSignup.new(feed: 'http://fake/feed').save
  end

  test "#govdelivery_url delegates to the govuk_delivery_client" do
    Whitehall.govuk_delivery_client.expects(:signup_url).with(feed_url)

    EmailSignup.new(feed: feed_url).govdelivery_url
  end

  test "#description provides a human-readable description of the filters being applied" do
    feed_url = feed_url("publications.atom?official_document_status=command_and_act_papers")

    assert_equal "publications which are command or act papers",
                 EmailSignup.new(feed: feed_url).description
  end

  def feed_url(feed_path = "publications.atom")
    "#{Whitehall.public_protocol}://#{Whitehall.public_host}/government/#{feed_path}"
  end

  def email_signup(feed_path)
    EmailSignup.new(feed: feed_url(feed_path))
  end
end
