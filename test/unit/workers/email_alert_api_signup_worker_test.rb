require 'test_helper'
require "gds_api/test_helpers/email_alert_api"

class EmailAlertApiSignupWorkerTest < ActiveSupport::TestCase
  include GdsApi::TestHelpers::EmailAlertApi

  setup do
    @worker = EmailAlertApiSignupWorker.new
  end

  test 'creates a new email alert api entry' do
    topic_id = "TOPIC_123"
    feed_url = "http://test.com/government/publications.atom?topic[]=energy"
    converted_hash = {"links" => {"topic" => ["a1234"]}, "email_document_supertype" => "publications"}
    parser = mock("Parser", convert: converted_hash)
    UrlToSubscriberListCriteria.expects(:new).with(feed_url).returns(parser)

    email_alert_api_does_not_have_subscriber_list(converted_hash.merge('gov_delivery_id' => topic_id))
    email_alert_api_creates_subscriber_list(converted_hash.merge('gov_delivery_id' => topic_id))

    @worker.perform(topic_id, feed_url)
  end

  test 'happy with existing email alert api entry' do
    topic_id = "TOPIC_123"
    feed_url = "http://test.com/government/publications.atom?topic[]=energy"
    converted_hash = {"links" => {"topic" => ["a1234"]}, "email_document_supertype" => "publications"}
    parser = mock("Parser", convert: converted_hash)
    UrlToSubscriberListCriteria.expects(:new).with(feed_url).returns(parser)

    email_alert_api_has_subscriber_list(converted_hash.merge('gov_delivery_id' => topic_id))

    @worker.perform(topic_id, feed_url)
  end

  test 'raises an error if the created subscriber list does not have the expected topic id' do
    topic_id = "TOPIC_123"
    feed_url = "http://test.com/government/publications.atom?topic[]=energy"
    converted_hash = {"links" => {"topic" => ["a1234"]}, "email_document_supertype" => "publications"}
    parser = mock("Parser", convert: converted_hash)
    UrlToSubscriberListCriteria.expects(:new).with(feed_url).returns(parser)

    email_alert_api_does_not_have_subscriber_list(converted_hash.merge('gov_delivery_id' => topic_id))
    email_alert_api_creates_subscriber_list(converted_hash.merge('gov_delivery_id' => "WRONG_TOPIC"))

    assert_raise EmailAlertApiSignupWorker::UnexpectedTopicID do
      @worker.perform(topic_id, feed_url)
    end
  end
end
