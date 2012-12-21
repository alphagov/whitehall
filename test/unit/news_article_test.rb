require "test_helper"

class NewsArticleTest < EditionTestCase
  include ActionDispatch::TestProcess

  should_allow_image_attachments
  should_have_first_image_pulled_out
  should_allow_a_summary_to_be_written
  should_protect_against_xss_and_content_attacks_on :title, :body, :summary, :change_note, :notes_to_editors

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

  test "can associate news articles with topical events" do
    news_article = create(:news_article)
    assert news_article.can_be_associated_with_topical_events?
    assert topical_event = news_article.topical_events.create(name: "Test", description: "Test")
    assert_equal [news_article], topical_event.news_articles
  end
end
