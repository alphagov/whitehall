require "test_helper"

class NewsArticleTest < EditionTestCase
  include ActionDispatch::TestProcess

  should_allow_image_attachments
  should_have_first_image_pulled_out
  should_protect_against_xss_and_content_attacks_on :title, :body, :summary, :change_note

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

  test "should allow setting of news article type" do
    news_article = build(:news_article, news_article_type: NewsArticleType::PressRelease)
    assert news_article.valid?
  end

  test "should be invalid without a news article type" do
    news_article = build(:news_article, news_article_type: nil)
    refute news_article.valid?
  end

  test 'imported news article are valid when the news_article_type is \'imported-awaiting-type\'' do
    news_article = build(:news_article, state: 'imported', news_article_type: NewsArticleType.find_by_slug('imported-awaiting-type'))
    assert news_article.valid?
  end

  test 'imported news article are not valid_as_draft? when the news_article_type is \'imported-awaiting-type\'' do
    news_article = build(:news_article, state: 'imported', news_article_type: NewsArticleType.find_by_slug('imported-awaiting-type'))
    refute news_article.valid_as_draft?
  end

  [:draft, :scheduled, :published, :archived, :submitted, :rejected].each do |state|
    test "#{state} news article is not valid when the news article type is 'imported-awaiting-type'" do
      news_article = build(:news_article, state: state, news_article_type: NewsArticleType.find_by_slug('imported-awaiting-type'))
      refute news_article.valid?
    end
  end

  test "search_index should include people" do
    news_article = create(:news_article, role_appointments: [create(:role_appointment), create(:role_appointment)])
    assert_equal news_article.role_appointments.map(&:person_id), news_article.search_index["people"]
  end
end
