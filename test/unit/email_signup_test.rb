require 'test_helper'

class EmailSignupTest < ActiveSupport::TestCase
  test "merges the local_government parameter with the feed URL" do
    assert_equal feed_url("feed"),
                 email_signup("feed").feed
    assert_equal feed_url("publications.atom"),
                  email_signup("publications.atom", false).feed
    assert_equal feed_url("feed?relevant_to_local_government=1"),
                 email_signup("feed", true).feed
    assert_equal feed_url("publications.atom?departments[]=all&relevant_to_local_government=1"),
                 email_signup("publications.atom?departments[]=all", true).feed
  end

  test "#save ensures that a relevant topic exists in GovDelivery using the feed and the signup description" do
    email_signup = EmailSignup.new(feed: feed_url)

    Whitehall.govuk_delivery_client.expects(:topic).with(feed_url, email_signup.description)

    assert email_signup.save
  end

  test "#save does not create a GovDelivery topic if the feed is missing" do
    Whitehall.govuk_delivery_client.expects(:topic).never

    refute EmailSignup.new.save
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

  def feed_url(feed_path="feed")
    "#{Whitehall.public_protocol}://#{Whitehall.public_host}/government/#{feed_path}"
  end

  def email_signup(feed_path, is_local_government = false)
    EmailSignup.new(feed: feed_url(feed_path), local_government: (is_local_government ? '1' : '0'))
  end
end
