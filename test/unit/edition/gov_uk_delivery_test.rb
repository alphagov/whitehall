require "test_helper"

class Edition::GovUkDeliveryTest < ActiveSupport::TestCase
  test "should build gov uk delivery query" do
    Edition::AuditTrail.whodunnit = create(:user)
    policy = create(:policy, topics: [create(:topic), create(:topic)])
    policy.first_published_at = Time.zone.now
    policy.major_change_published_at = Time.zone.now

    #Assert gds api adapters gets called with the correct values
    #{:title=>"policy-title", :summary=>"policy-summary", :link=>"/government/policies/policy-title", :tags=>["/government/policies?departments%5B%5D=organisation-2&topics%5B%5D=topic-1", "/government/policies?departments%5B%5D=organisation-2&topics%5B%5D=topic-2"]}
    policy.publish!

    news_article = create(:news_article, related_editions: [policy])
    news_article.first_published_at = Time.zone.now
    news_article.major_change_published_at = Time.zone.now

    #{:title=>"news-title", :summary=>"news-summary", :link=>"/government/news/news-title", :tags=>["/government/announcements?announcement_type_option=press-releases&departments%5B%5D=organisation-3&topics%5B%5D=topic-1", "/government/announcements?announcement_type_option=press-releases&departments%5B%5D=organisation-3&topics%5B%5D=topic-2"]}
    news_article.publish!

    publication = create(:publication, related_editions: [policy])
    publication.first_published_at = Time.zone.now
    publication.major_change_published_at = Time.zone.now

    #{:title=>"publication-title", :summary=>"publication-summary", :link=>"/government/publications/publication-title", :tags=>["/government/publications?departments%5B%5D=organisation-4&publication_filter_option=policy-papers&topics%5B%5D=topic-1", "/government/publications?departments%5B%5D=organisation-4&publication_filter_option=policy-papers&topics%5B%5D=topic-2"]}
    publication.publish!
  end
end
