require "test_helper"

class NewsArticleTest < ActiveSupport::TestCase
  include ActionDispatch::TestProcess

  should_allow_image_attachments
  should_have_first_image_pulled_out
  should_protect_against_xss_and_content_attacks_on :title, :body, :summary, :change_note

  test "should be able to relate to other editions" do
    article = build(:news_article)
    assert article.can_be_related_to_policies?
  end

  test "can associate news articles with topical events" do
    news_article = create(:news_article)
    assert news_article.can_be_associated_with_topical_events?
    assert topical_event = news_article.topical_events.create(name: "Test", description: "Test")
    assert_equal [news_article], topical_event.news_articles
  end

  test "should allow setting of news article type" do
    news_article = build(:news_article_press_release)
    assert news_article.valid?
  end

  test "should be invalid without a news article type" do
    news_article = build(:news_article, news_article_type: nil)
    refute news_article.valid?
  end

  test "superseded news articles are valid with the 'unknown' news_article_type" do
    news_article = build(:superseded_news_article, news_article_type: NewsArticleType::Unknown)
    assert news_article.valid?
  end

  test "non-English should be invalid for non-world-news-story types" do
    non_foreign_language_news_types = [
      NewsArticleType::NewsStory,
      NewsArticleType::PressRelease,
      NewsArticleType::GovernmentResponse,
    ]

    non_foreign_language_news_types.each do |news_type|
      news_article = build(:news_article, news_article_type: news_type)
      news_article.primary_locale = 'fr'
      refute news_article.valid?
    end
  end

  test "search_index should include people" do
    news_article = create(:news_article, role_appointments: [create(:role_appointment), create(:role_appointment)])
    assert_equal news_article.role_appointments.map(&:slug), news_article.search_index["people"]
  end

  test "search_format_types tags the news article as a news-article and announcement" do
    news_article = build(:news_article)
    assert news_article.search_format_types.include?('news-article')
    assert news_article.search_format_types.include?('announcement')
  end

  test "search_format_types includes search_format_types of the speech_type" do
    news_article_type = mock
    news_article_type.responds_like(NewsArticleType.new)
    news_article_type.stubs(:search_format_types).returns (['stuff-innit', 'other-thing'])
    news_article = build(:news_article)
    news_article.stubs(:news_article_type).returns(news_article_type)
    assert news_article.search_format_types.include?('stuff-innit')
    assert news_article.search_format_types.include?('other-thing')
  end

  test "should be translatable" do
    assert build(:news_article).translatable?
  end

  test "is not translatable when non-English" do
    refute build(:news_article, primary_locale: :es).translatable?
  end

  test "#world_news_story? returns false" do
    article = build(:news_article)

    refute article.world_news_story?
  end

  test "can be related to policies" do
    article = build(:news_article)

    assert article.can_be_related_to_policies?
  end

  test "can associate news articles with worldwide organisations" do
    news_article = create(:news_article)
    assert news_article.can_be_associated_with_worldwide_organisations?
    assert news_article.worldwide_organisations.create(name: "Zimbabwean Embassy")
  end

  test "is invalid when associating a worldwide organisation to a non-World-news-story news article type" do
    non_world_news_story_news_article_types = [
      NewsArticleType::NewsStory,
      NewsArticleType::PressRelease,
      NewsArticleType::GovernmentResponse,
    ]

    non_world_news_story_news_article_types.each do |news_article_type|
      news_article = build(:news_article, news_article_type: news_article_type)
      news_article.worldwide_organisations.build(name: "Zimbabwean Embassy")
      refute news_article.valid?
      assert news_article.errors[:worldwide_organisations].include?("must be blank")
    end
  end
end

class WorldNewsStoryTypeNewsArticleTest < ActiveSupport::TestCase
  test "#world_news_story? returns true" do
    article = build(:news_article_world_news_story)
    assert article.world_news_story?
  end

  test "non-English primary locale should be valid" do
    news_article = build(:news_article_world_news_story)
    news_article.primary_locale = 'fr'
    assert news_article.valid?
  end

  test "is invalid when not associating a worldwide organisation" do
    news_article = build(:news_article_world_news_story)
    news_article.worldwide_organisations = []
    refute news_article.valid?
    assert news_article.errors[:worldwide_organisations].include?("at least one required")
  end

  test "can't be related to policies" do
    article = build(:news_article_world_news_story)

    refute article.can_be_related_to_policies?
  end

  test "is invalid if a policy is associated" do
    article = build(:news_article_world_news_story)
    article.stubs(:edition_policies).returns([Policy.new({})])

    refute article.valid?
    assert_equal ["You can't tag a world news story to policies, please remove policy"], article.errors[:base]
  end

  test "are invalid if associated with a minister" do
    article = build(:news_article_world_news_story)
    article.role_appointments << build(:ministerial_role_appointment)

    refute article.valid?
    assert_equal ["You can't tag a world news story to ministers, please remove minister"],
      article.errors[:base]
  end

  test "is valid when not associating an organisation" do
    news_article = build(:news_article_world_news_story)
    news_article.organisations = []
    assert news_article.valid?
  end

  test "is invalid when associating an organisation" do
    news_article = build(:news_article_world_news_story)
    news_article.edition_organisations.build(organisation: FactoryGirl.build(:organisation))

    refute news_article.valid?
    assert_equal ["You can't tag a world news story to organisations, please remove organisation"],
      news_article.errors[:base]
  end
end
