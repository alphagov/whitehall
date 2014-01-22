require 'test_helper'

class EmailSignupTest < ActiveSupport::TestCase
  test "merges the local_government parameter with the feed URL" do
    assert_equal "https://#{Whitehall.public_host}/government/feed.atom?relevant_to_local_government=1",
                 email_signup("feed.atom", true).feed
    assert_equal "https://#{Whitehall.public_host}/government/feed.atom",
                 email_signup("feed.atom", false).feed
    assert_equal "https://#{Whitehall.public_host}/government/feed.atom",
                 email_signup("feed.atom").feed

    assert_equal "https://#{Whitehall.public_host}/government/feed.atom?departments[]=all&relevant_to_local_government=1",
                 email_signup("feed.atom?departments[]=all", true).feed
  end

  test ".create ensures that a relevant topic exists in GovDelivery using the feed and the signup description" do
    feed_url = "https://#{Whitehall.public_host}/government/feed.atom"
    signup_description = 'Example Description'
    EmailSignup.any_instance.stubs(description: signup_description)

    Whitehall.govuk_delivery_client.expects(:topic).with(feed_url, signup_description)

    EmailSignup.create(feed_url)
  end

  test ".create does not create a GovDelivery topic if the feed is missing" do
    Whitehall.govuk_delivery_client.expects(:topic).never

    EmailSignup.create
  end

  test "#govdelivery_url delegates to the govuk_delivery_client" do
    feed_url = "https://#{Whitehall.public_host}/government/feed.atom"

    Whitehall.govuk_delivery_client.expects(:signup_url).with(feed_url)

    EmailSignup.new(feed_url).govdelivery_url
  end

  test "#description provides a human-readable description of the filters being applied" do
    feed_url = 'http://example.com/government/publications.atom?departments%5B%5D=department-of-health&keywords=&official_document_status=command_and_act_papers&publication_filter_option=all&topics%5B%5D=all'
    assert_match /publication/, EmailSignup.new(feed_url).description
  end

  def email_signup(url_fragment, is_local_government = false)
    EmailSignup.new("https://#{Whitehall.public_host}/government/#{url_fragment}", is_local_government)
  end
end
