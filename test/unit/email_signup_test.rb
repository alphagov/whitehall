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

  test "validation requires the correct domain" do
    refute EmailSignup.new(feed: 'https://www.example.com/government/feed.atom').valid?
    assert EmailSignup.new(feed: "https://#{Whitehall.public_host}/government/feed.atom").valid?
  end

  test "validation requires the correct scheme (protocol)" do
    refute EmailSignup.new(feed: "http://#{Whitehall.public_host}/government/feed.atom").valid?
    assert EmailSignup.new(feed: "https://#{Whitehall.public_host}/government/feed.atom").valid?
  end

  test "validation requires a correct path" do
    refute EmailSignup.new(feed: "https://#{Whitehall.public_host}/example/feed.atom").valid?
    assert EmailSignup.new(feed: "https://#{Whitehall.public_host}/government/feed.atom").valid?
  end

  test "validation requires a correct document_type parameter" do
    create(:document, document_type: "Policy")

    assert EmailSignup.new(feed: "https://#{Whitehall.public_host}/government/feed.atom").valid?
    assert EmailSignup.new(feed: "https://#{Whitehall.public_host}/government/announcements.atom").valid?
    assert EmailSignup.new(feed: "https://#{Whitehall.public_host}/government/feed.atom?document_type=policies").valid?
    refute EmailSignup.new(feed: "https://#{Whitehall.public_host}/government/feed.atom?document_type=not_a_document_type").valid?
    refute EmailSignup.new(feed: "https://#{Whitehall.public_host}/government/announcements.atom?document_type=not_a_document_type").valid?
  end

  test "validation requires correct params for the generic feed" do
    refute EmailSignup.new(feed: "https://#{Whitehall.public_host}/government/feed.atom?not_a_valid_param=all").valid?

    assert EmailSignup.new(feed: "https://#{Whitehall.public_host}/government/feed.atom?departments[]=all").valid?
    assert EmailSignup.new(feed: "https://#{Whitehall.public_host}/government/feed.atom?topics[]=all").valid?
    assert EmailSignup.new(feed: "https://#{Whitehall.public_host}/government/feed.atom?world_locations[]=all").valid?
    assert EmailSignup.new(feed: "https://#{Whitehall.public_host}/government/feed.atom?official_document_status=all").valid?

    assert EmailSignup.new(feed: "https://#{Whitehall.public_host}/government/feed.atom?departments[]=all&topics[]=all&world_locations[]=all&official_document_status=all").valid?
  end

  test "validation requires correct params for publications" do
    refute EmailSignup.new(feed: "https://#{Whitehall.public_host}/government/feed.atom?publication_filter_option=all").valid?
    assert EmailSignup.new(feed: "https://#{Whitehall.public_host}/government/publications.atom?publication_filter_option=all").valid?
    refute EmailSignup.new(feed: "https://#{Whitehall.public_host}/government/publications.atom?publication_filter_option=not_a_valid_filter_option").valid?
  end

  test "validation requires correct params for announcements" do
    refute EmailSignup.new(feed: "https://#{Whitehall.public_host}/government/feed.atom?announcement_type_option=all").valid?
    assert EmailSignup.new(feed: "https://#{Whitehall.public_host}/government/announcements.atom?announcement_type_option=all").valid?
    refute EmailSignup.new(feed: "https://#{Whitehall.public_host}/government/announcements.atom?announcement_type_option=not_a_valid_filter_option").valid?
  end

end
