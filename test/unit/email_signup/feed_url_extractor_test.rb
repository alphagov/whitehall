require 'test_helper'

class EmailSignup::FeedUrlExtractorTest < ActiveSupport::TestCase
  test 'given an alert with a document_type prefixed with "publication_type_" the url path is /government/publications.atom' do
    a = EmailSignup::Alert.new(document_type: 'publication_type_consultations')
    assert_match(/\/government\/publications.atom/, EmailSignup::FeedUrlExtractor.new(a).feed_url)
  end

  test 'given an alert with a document_type of "publication_type_all" the url should have no publication_filter_option param' do
    a = EmailSignup::Alert.new(document_type: 'publication_type_all')
    refute_match(/publication_filter_option\=/, EmailSignup::FeedUrlExtractor.new(a).feed_url)
  end

  test 'given an alert with a document_type prefixed with "publication_type_" but not "publication_type_all" the url should have a publication_filter_option param with the prefix removed' do
    a = EmailSignup::Alert.new(document_type: 'publication_type_consultations')
    assert_match(/publication_filter_option=consultations/, EmailSignup::FeedUrlExtractor.new(a).feed_url)
  end

  test 'given an alert with a document_type prefixed with "announcement_type_" the url path is /government/announcements.atom' do
    a = EmailSignup::Alert.new(document_type: 'announcement_type_speeches')
    assert_match(/\/government\/announcements.atom/, EmailSignup::FeedUrlExtractor.new(a).feed_url)
  end

  test 'given an alert with a document_type of "announcement_type_all" the url should have no announcement_filter_option param' do
    a = EmailSignup::Alert.new(document_type: 'announcement_type_all')
    refute_match(/announcement_filter_option\=/, EmailSignup::FeedUrlExtractor.new(a).feed_url)
  end

  test 'given an alert with a document_type prefixed with "announcement_type_" but not "announcement_type_all" the url should have an announcement_filter_option param with the prefix removed' do
    a = EmailSignup::Alert.new(document_type: 'announcement_type_press-releases')
    assert_match(/announcement_filter_option=press-releases/, EmailSignup::FeedUrlExtractor.new(a).feed_url)
  end

  test 'given an alert with a document_type of "policy_type_all" the url path is /government/policies.atom' do
    a = EmailSignup::Alert.new(document_type: 'policy_type_all')
    assert_match(/\/government\/policies.atom/, EmailSignup::FeedUrlExtractor.new(a).feed_url)
  end

  test 'given an alert with a document_type of "all" the url path is /government/policies.atom' do
    a = EmailSignup::Alert.new(document_type: 'all')
    assert_match(/\/government\/feed/, EmailSignup::FeedUrlExtractor.new(a).feed_url)
  end

  test 'given an alert with an organisation of "all" the url should have no departments[] param' do
    a = EmailSignup::Alert.new(document_type: 'all', organisation: 'all')
    refute_match(/departments\%5B\%5D\=/, EmailSignup::FeedUrlExtractor.new(a).feed_url)
  end

  test 'given an alert with an organisation not "all" the url should have a departments[]= param for it' do
    a = EmailSignup::Alert.new(document_type: 'all', organisation: 'decc')
    assert_match(/departments\%5B\%5D\=decc/, EmailSignup::FeedUrlExtractor.new(a).feed_url)
  end

  test 'given an alert with a topic of "all" the url should have no topics[] param' do
    a = EmailSignup::Alert.new(document_type: 'all', topic: 'all')
    refute_match(/topics\%5B\%5D\=/, EmailSignup::FeedUrlExtractor.new(a).feed_url)
  end

  test 'given an alert with an topic not "all" the url should have a topics[]= param for it' do
    a = EmailSignup::Alert.new(document_type: 'all', topic: 'environment')
    assert_match(/topics\%5B\%5D\=environment/, EmailSignup::FeedUrlExtractor.new(a).feed_url)
  end
end

