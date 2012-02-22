require "test_helper"

class NewsArticleTest < ActiveSupport::TestCase
  include DocumentBehaviour
  include ActionDispatch::TestProcess

  should_be_featurable :news_article

  test "should be able to relate to other documents" do
    article = build(:news_article)
    assert article.can_be_related_to_policies?
  end

  test "#policy_topics includes policy topics associated with related published policies" do
    related_policy = create(:published_policy, policy_topics: [create(:policy_topic), create(:policy_topic)])
    news_article = create(:news_article, related_policies: [related_policy])
    assert_equal related_policy.policy_topics.sort, news_article.policy_topics.sort
  end

  test "#policy_topics excludes policy topics associated with related unpublished policies" do
    related_policy = create(:draft_policy, policy_topics: [create(:policy_topic), create(:policy_topic)])

    news_article = create(:news_article, related_policies: [related_policy])
    assert_equal [], news_article.policy_topics
  end

  test "#policy_topics includes each related policy topic only once, even if associated multiple times" do
    policy_topic = create(:policy_topic)
    first_related_policy = create(:published_policy, policy_topics: [policy_topic])
    second_related_policy = create(:published_policy, policy_topics: [policy_topic])
    news_article = create(:news_article, related_policies: [first_related_policy, second_related_policy])
    assert_equal [policy_topic], news_article.policy_topics
  end

  test "should build a draft copy retaining any associated feature image with responds to present" do
    featuring_image = fixture_file_upload('portas-review.jpg')
    news_article = create(:featured_news_article, featuring_image: featuring_image)
    assert news_article.featuring_image.present?, "original feature image should be present for this test to be valid"

    draft_article = news_article.create_draft(create(:policy_writer))
    assert draft_article.featuring_image.present?
  end

  test "should allow featuring image" do
    news_article = build(:news_article)
    assert news_article.allows_featuring_image?
  end

  test "uses first image as lead image" do
    news_article = build(:news_article)
    image = create(:image, document: news_article)
    assert_equal image, news_article.lead_image
  end

end
