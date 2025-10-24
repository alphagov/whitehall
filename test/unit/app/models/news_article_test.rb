require "test_helper"

class NewsArticleTest < ActiveSupport::TestCase
  include ActionDispatch::TestProcess

  should_allow_image_attachments
  should_have_custom_lead_image
  should_protect_against_xss_and_content_attacks_on :news_article, :title, :body, :summary, :change_note

  test "can associate news articles with topical events" do
    news_article = create(:news_article)
    assert news_article.can_be_associated_with_topical_events?
    assert topical_event = news_article.topical_events.create!(name: "Test", description: "Test", summary: "Test")
    assert_equal [news_article], topical_event.news_articles
  end

  test "allows setting of news article type" do
    news_article = build(:news_article_press_release)
    assert news_article.valid?
  end

  test "is invalid without a news article type" do
    news_article = build(:news_article, news_article_type: nil)
    assert_not news_article.valid?
  end

  test "non-English locale is invalid for non-world-news-story types" do
    non_foreign_language_news_types = [
      NewsArticleType::NewsStory,
      NewsArticleType::PressRelease,
      NewsArticleType::GovernmentResponse,
    ]

    non_foreign_language_news_types.each do |news_type|
      news_article = build(:news_article, news_article_type: news_type)
      news_article.primary_locale = "fr"
      assert_not news_article.valid?
    end
  end

  test "is translatable" do
    assert build(:news_article).translatable?
  end

  test "is not translatable when non-English" do
    assert_not build(:news_article, primary_locale: :es).translatable?
  end

  test "#world_news_story? returns false" do
    article = build(:news_article)

    assert_not article.world_news_story?
  end

  test "can associate world news stories with worldwide organisations" do
    news_article = create(:news_article_world_news_story)
    assert news_article.worldwide_organisation_association_required?
    worldwide_organisation = build(:worldwide_organisation, :with_document, title: "Zimbabwean Embassy")
    assert news_article.worldwide_organisation_documents << worldwide_organisation.document
  end

  test "is invalid when associating a worldwide organisation to a non-World-news-story news article type" do
    non_world_news_story_news_article_types = [
      NewsArticleType::NewsStory,
      NewsArticleType::PressRelease,
      NewsArticleType::GovernmentResponse,
    ]

    non_world_news_story_news_article_types.each do |news_article_type|
      news_article = build(:news_article, news_article_type:)
      worldwide_organisation = build(:worldwide_organisation, :with_document, title: "Zimbabwean Embassy")
      news_article.worldwide_organisation_documents << worldwide_organisation.document
      assert_not news_article.valid?
      assert news_article.errors[:worldwide_organisation_documents].include?("must be blank")
    end
  end
end

class WorldNewsStoryTypeNewsArticleTest < ActiveSupport::TestCase
  test "#world_news_story? returns true" do
    article = build(:news_article_world_news_story)
    assert article.world_news_story?
  end

  test "non-English primary locale is valid" do
    news_article = build(:news_article_world_news_story)
    news_article.primary_locale = "fr"
    assert news_article.valid?
  end

  test "is invalid when not associating an worldwide organisation" do
    news_article = build(:news_article_world_news_story)

    news_article.worldwide_organisations = []

    assert_not news_article.valid?
    assert news_article.errors[:worldwide_organisations].include?("at least one required")
  end

  test "are invalid if associated with a minister" do
    article = build(:news_article_world_news_story)
    article.role_appointments << build(:ministerial_role_appointment)

    assert_not article.valid?
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
    news_article.edition_organisations.build(organisation: FactoryBot.build(:organisation))

    assert_not news_article.valid?
    assert_equal ["You can't tag a world news story to organisations, please remove organisation"],
                 news_article.errors[:base]
  end

  test "is invalid without a world_location" do
    article = build(:news_article_world_news_story)
    article.world_locations.clear

    assert_not article.valid?
    assert_equal ["at least one required"],
                 article.errors[:world_locations]
  end

  test "is valid when removing an organisation after changing type" do
    news_article = create(:news_article_news_story)

    news_article.news_article_type = NewsArticleType::WorldNewsStory
    worldwide_organisation = build(:worldwide_organisation, :with_document, title: "Zimbabwean Embassy")
    news_article.worldwide_organisation_documents << worldwide_organisation.document
    news_article.world_locations << build(:world_location)
    news_article.lead_organisation_ids = []

    assert news_article.valid?
  end
end
