require 'test_helper'

class EmailSignupTest < ActiveSupport::TestCase

  test "merges the local_government parameter with the feed URL" do
    assert_equal 'http://example.com/test.atom?relevant_to_local_government=1',
                 EmailSignup.new(feed: 'http://example.com/test.atom', local_government: "1").feed
    assert_equal 'http://example.com/test.atom',
                 EmailSignup.new(feed: 'http://example.com/test.atom', local_government: "0").feed
    assert_equal 'http://example.com/test.atom',
                 EmailSignup.new(feed: 'http://example.com/test.atom').feed

    assert_equal 'http://example.com/test.atom?example_parameter=test&relevant_to_local_government=1',
                 EmailSignup.new(feed: 'http://example.com/test.atom?example_parameter=test', local_government: "1").feed
  end

  test "::create ensures that a relevant topic exists in GovDelivery using the feed and the signup description" do
    feed_url = 'http://www.example.com/test.atom'
    signup_description = 'Example Description'
    EmailSignup.any_instance.stubs(description: signup_description)

    Whitehall.govuk_delivery_client.expects(:topic).with(feed_url, signup_description)

    EmailSignup.create(feed: feed_url)
  end

  test "#govdelivery_url delegates to the govuk_delivery_client" do
    feed_url = 'http://www.example.com/test.atom'

    Whitehall.govuk_delivery_client.expects(:signup_url).with(feed_url)

    EmailSignup.new(feed: feed_url).govdelivery_url
  end

  test "#description provides a human-readable description of the filters being applied" do
    feed_url = 'http://example.com/government/publications.atom?&departments%5B%5D=department-of-health&keywords=&official_document_status=command_and_act_papers&publication_filter_option=all&topics%5B%5D=all'
    assert_match /publication/, EmailSignup.new(feed: feed_url).description
  end

end
