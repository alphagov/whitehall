require "test_helper"
require 'gds_api/test_helpers/gov_uk_delivery'

class Edition::GovUkDeliveryTest < ActiveSupport::TestCase
  include GdsApi::TestHelpers::GovUkDelivery

  test "should notify govuk_delivery on publishing policies" do
    Edition::AuditTrail.whodunnit = create(:user)
    policy = create(:policy, topics: [create(:topic), create(:topic)])
    policy.first_published_at = Time.zone.now
    policy.major_change_published_at = Time.zone.now

    policy.stubs(:govuk_delivery_tags).returns(['http://example.com/feed'])
    govuk_delivery_create_notification_success(['http://example.com/feed'], policy.title, '')
    policy.publish!

  end

  test "should notify govuk_delivery on publishing news articles" do
    news_article = create(:news_article)
    news_article.first_published_at = Time.zone.now
    news_article.major_change_published_at = Time.zone.now

    news_article.stubs(:govuk_delivery_tags).returns(['http://example.com/feed'])
    govuk_delivery_create_notification_success(['http://example.com/feed'], news_article.title, '')
    news_article.publish!
  end

  test "should notify govuk_delivery on publishing publications" do

    publication = create(:publication)
    publication.first_published_at = Time.zone.now
    publication.major_change_published_at = Time.zone.now

    publication.stubs(:govuk_delivery_tags).returns(['http://example.com/feed'])
    govuk_delivery_create_notification_success(['http://example.com/feed'], publication.title, '')
    publication.publish!
  end
end
