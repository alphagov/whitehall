require "test_helper"
require 'gds_api/test_helpers/gov_uk_delivery'

class GovUkDeliveryTest < ActiveSupport::TestCase
  include GdsApi::TestHelpers::GovUkDelivery

  setup do
    # Use the real GovUkDelivery client
    Whitehall.govuk_delivery_client = GdsApi::GovUkDelivery.new(Plek.find('govuk-delivery'))
  end

  test "Publishing a publication calls govuk-delivery API" do
    Edition::AuditTrail.whodunnit = create(:user)
    publication = create(:submitted_publication, topics: [create(:topic), create(:topic)])
    publication.first_published_at = Time.zone.now
    publication.major_change_published_at = Time.zone.now
    Whitehall::GovUkDelivery::SubscriptionUrlGenerator.any_instance.stubs(:subscription_urls).returns(['http://example.com/feed'])
    Whitehall::GovUkDelivery::EmailFormatter.any_instance.stubs(:email_body).returns('body')

    expected_payload = { feed_urls: ['http://example.com/feed'], subject: "Policy paper: #{publication.title}", body: 'body' }
    stub = stub_gov_uk_delivery_post_request('notifications', expected_payload).to_return(created_response_hash)
    stub_publishing_api_registration_for(publication)
    assert Whitehall.edition_services.publisher(publication).perform!
    assert_requested stub
  end

  test "API 400 errors calls don't block publishing" do
    Edition::AuditTrail.whodunnit = create(:user)
    publication = create(:submitted_publication, topics: [create(:topic), create(:topic)])
    publication.first_published_at = Time.zone.now
    publication.major_change_published_at = Time.zone.now
    Whitehall::GovUkDelivery::SubscriptionUrlGenerator.any_instance.stubs(:subscription_urls).returns(['http://example.com/feed'])
    Whitehall::GovUkDelivery::EmailFormatter.any_instance.stubs(:email_body).returns('body')

    expected_payload = { feed_urls: ['http://example.com/feed'], subject: "Policy paper: #{publication.title}", body: 'body' }
    stub = stub_gov_uk_delivery_post_request('notifications', expected_payload).to_return(error_response_hash)
    stub_publishing_api_registration_for(publication)

    assert Whitehall.edition_services.publisher(publication).perform!
    assert_requested stub
  end

  private

  def created_response_hash
    { body: '', status: 201 }
  end

  def error_response_hash
    { body: 'No subscribers', status: 400 }
  end
end
