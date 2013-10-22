require "test_helper"
require 'gds_api/test_helpers/gov_uk_delivery'

class GovUkDeliveryTest < ActiveSupport::TestCase
  include GdsApi::TestHelpers::GovUkDelivery

  setup do
    # Use the real GovUkDelivery client
    Whitehall.govuk_delivery_client = GdsApi::GovUkDelivery.new(Plek.current.find('govuk-delivery'))
    Delayed::Job.destroy_all
  end

  test "Publishing a policy calls govuk-delivery API" do
    without_delay! do
      Edition::AuditTrail.whodunnit = create(:user)
      policy = create(:submitted_policy, topics: [create(:topic), create(:topic)])
      policy.first_published_at = Time.zone.now
      policy.major_change_published_at = Time.zone.now
      Whitehall::GovUkDelivery::GovUkDeliveryEndPoint.any_instance.stubs(:tags).returns(['http://example.com/feed'])
      Whitehall::GovUkDelivery::GovUkDeliveryEndPoint.any_instance.stubs(:email_body).returns('body')

      expected_payload = { feed_urls: ['http://example.com/feed'], subject: "Policy: #{policy.title}", body: 'body' }
      stub = stub_gov_uk_delivery_post_request('notifications', expected_payload).to_return(created_response_hash)

      assert policy.publish!
      assert_requested stub
    end
  end

  test "API 400 errors calls don't block publishing" do
    without_delay! do
      Edition::AuditTrail.whodunnit = create(:user)
      policy = create(:submitted_policy, topics: [create(:topic), create(:topic)])
      policy.first_published_at = Time.zone.now
      policy.major_change_published_at = Time.zone.now
      Whitehall::GovUkDelivery::GovUkDeliveryEndPoint.any_instance.stubs(:tags).returns(['http://example.com/feed'])
      Whitehall::GovUkDelivery::GovUkDeliveryEndPoint.any_instance.stubs(:email_body).returns('body')

      expected_payload = { feed_urls: ['http://example.com/feed'], subject: "Policy: #{policy.title}", body: 'body' }
      stub = stub_gov_uk_delivery_post_request('notifications', expected_payload).to_return(error_response_hash)

      assert policy.publish!
      assert_requested stub
    end
  end

  private

  def created_response_hash
    { body: '', status: 201 }
  end

  def error_response_hash
    { body: 'No subscribers', status: 400 }
  end
end
