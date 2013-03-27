require "test_helper"

class Edition::GovUkDeliveryTest < ActiveSupport::TestCase
  test "should build gov uk delivery query" do
    Edition::AuditTrail.whodunnit = create(:user)
    policy = create(:policy, topics: [create(:topic), create(:topic)])
    policy.first_published_at = Time.zone.now
    policy.major_change_published_at = Time.zone.now

    policy.expects(:notify_govuk_delivery).once

    policy.publish!

    news_article = create(:news_article, related_editions: [policy])
    news_article.first_published_at = Time.zone.now
    news_article.major_change_published_at = Time.zone.now

    news_article.expects(:notify_govuk_delivery).once

    news_article.publish!

    publiction = create(:publication, related_editions: [policy])
    publiction.first_published_at = Time.zone.now
    publiction.major_change_published_at = Time.zone.now

    publiction.expects(:notify_govuk_delivery).once

    publiction.publish!

  end

end