require 'test_helper'

class EmailSignup::GovUkDeliveryRedirectUrlExtractorTest < ActiveSupport::TestCase
  test 'given an alert, it extracts a feed_url for it by supplying it to a FeedUrlExtractor' do
    a = EmailSignup::Alert.new
    r = EmailSignup::GovUkDeliveryRedirectUrlExtractor.new(a)
    feed_url_extractor = stub(feed_url: 'http://govuk.example.com/feed.atom')
    EmailSignup::FeedUrlExtractor.expects(:new).with(a).returns(feed_url_extractor)

    assert_equal 'http://govuk.example.com/feed.atom', r.feed_url_for_topic
  end

  test 'given an alert, it extracts a title for it by supplying it to a TitleExtractor' do
    a = EmailSignup::Alert.new
    r = EmailSignup::GovUkDeliveryRedirectUrlExtractor.new(a)
    title_extractor = stub(title: 'Some stuff about things')
    EmailSignup::TitleExtractor.expects(:new).with(a).returns(title_extractor)

    assert_equal 'Some stuff about things', r.title_for_topic
  end

  test 'given an alert, it requests the topic for it from the govuk_delivery client, using the feed_url and title' do
    a = EmailSignup::Alert.new
    r = EmailSignup::GovUkDeliveryRedirectUrlExtractor.new(a)
    r.stubs(:title_for_topic).returns 'Some stuff about things'
    r.stubs(:feed_url_for_topic).returns 'http://govuk.example.com/feed.atom'
    Whitehall.govuk_delivery_client.expects(:topic).with('http://govuk.example.com/feed.atom', 'Some stuff about things').returns :a_gov_uk_delivery_topic

    assert_equal :a_gov_uk_delivery_topic, r.gov_uk_delivery_topic
  end

  test 'given an alert, it requests the new signup url for it from the govuk_delivery client, using gov_uk_delivery_topic' do
    a = EmailSignup::Alert.new
    r = EmailSignup::GovUkDeliveryRedirectUrlExtractor.new(a)
    r.stubs(:gov_uk_delivery_topic).returns :a_gov_uk_delivery_topic
    Whitehall.govuk_delivery_client.expects(:new_signup_url).with(:a_gov_uk_delivery_topic).returns 'http://govdelivery.example.com/new-signup?topic_id=a_gov_uk_delivery_topic'

    assert_equal 'http://govdelivery.example.com/new-signup?topic_id=a_gov_uk_delivery_topic', r.redirect_url
  end
end
