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

  test ".create ensures that a relevant topic exists in GovDelivery using the feed and the signup description" do
    signup_description = 'Example Description'
    EmailSignup.any_instance.stubs(description: signup_description)

    Whitehall.govuk_delivery_client.expects(:topic).with(feed_url, signup_description)

    EmailSignup.create(feed: feed_url)
  end

  test ".create does not create a GovDelivery topic if the feed is missing" do
    Whitehall.govuk_delivery_client.expects(:topic).never

    EmailSignup.create
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
