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
    policy.stubs(:govuk_delivery_email_body).returns('')
    request = govuk_delivery_create_notification_success(['http://example.com/feed'], policy.title, '')

    assert policy.publish!
    assert_requested request
  end

  test "Failing API calls don't block publishing" do
    Edition::AuditTrail.whodunnit = create(:user)
    policy = create(:policy, topics: [create(:topic), create(:topic)])
    policy.first_published_at = Time.zone.now
    policy.major_change_published_at = Time.zone.now
    policy.stubs(:govuk_delivery_tags).returns(['http://example.com/feed'])
    policy.stubs(:govuk_delivery_email_body).returns('')
    request = govuk_delivery_create_notification_error(['http://example.com/feed'], policy.title, '')

    assert policy.publish!
    assert_requested request
  end
end
