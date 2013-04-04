require "test_helper"
require 'gds_api/test_helpers/gov_uk_delivery'

class GovUkDeliveryTest < ActiveSupport::TestCase
  include GdsApi::TestHelpers::GovUkDelivery

  setup do
    # Use the real GovUkDelivery client
    Whitehall.govuk_delivery_client = GdsApi::GovUkDelivery.new(Plek.current.find('govuk-delivery'))
  end

  test "Publishing a policy calls govuk-delivery API" do
    Edition::AuditTrail.whodunnit = create(:user)
    policy = create(:policy, topics: [create(:topic), create(:topic)])
    policy.first_published_at = Time.zone.now
    policy.major_change_published_at = Time.zone.now
    policy.stubs(:govuk_delivery_tags).returns(['http://example.com/feed'])
    policy.stubs(:govuk_delivery_email_body).returns('body')

    expected_payload = { feed_urls: ['http://example.com/feed'], subject: policy.title, body: 'body' }
    stub = stub_gov_uk_delivery_post_request('notifications', expected_payload).to_return(created_response_hash)

    assert policy.publish!
    assert_requested stub
  end

  test "Failing API calls don't block publishing" do
    Edition::AuditTrail.whodunnit = create(:user)
    policy = create(:policy, topics: [create(:topic), create(:topic)])
    policy.first_published_at = Time.zone.now
    policy.major_change_published_at = Time.zone.now
    policy.stubs(:govuk_delivery_tags).returns(['http://example.com/feed'])
    policy.stubs(:govuk_delivery_email_body).returns('body')

    expected_payload = { feed_urls: ['http://example.com/feed'], subject: policy.title, body: 'body' }
    stub = stub_gov_uk_delivery_post_request('notifications', expected_payload).to_return(error_response_hash)

    assert policy.publish!
    assert_requested stub
  end

  private

  def created_response_hash
    { body: '', status: 201 }
  end

  def error_response_hash
    { body: '', status: 500 }
  end
end
