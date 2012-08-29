require "test_helper"

class NewsArticleTest < ActiveSupport::TestCase
  include DocumentBehaviour
  include ActionDispatch::TestProcess

  test "should be able to relate to other editions" do
    article = build(:news_article)
    assert article.can_be_related_to_policies?
  end

  test "#topics includes topics associated with related published policies" do
    related_policy = create(:published_policy, topics: [create(:topic), create(:topic)])
    news_article = create(:news_article, related_policies: [related_policy])
    assert_equal related_policy.topics.sort, news_article.topics.sort
  end

  test "#topics excludes topics associated with related unpublished policies" do
    related_policy = create(:draft_policy, topics: [create(:topic), create(:topic)])

    news_article = create(:news_article, related_policies: [related_policy])
    assert_equal [], news_article.topics
  end

  test "#topics includes each related topic only once, even if associated multiple times" do
    topic = create(:topic)
    first_related_policy = create(:published_policy, topics: [topic])
    second_related_policy = create(:published_policy, topics: [topic])
    news_article = create(:news_article, related_policies: [first_related_policy, second_related_policy])
    assert_equal [topic], news_article.topics
  end

  test "uses first image as lead image" do
    news_article = build(:news_article)
    image = create(:image, edition: news_article)
    assert_equal image, news_article.lead_image
  end

end
