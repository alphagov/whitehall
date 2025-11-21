FactoryBot.define do
  factory :news_article, class: NewsArticle, parent: :edition, traits: %i[with_organisations] do
    title { "news-title" }
    summary { "news-summary" }
    body { "news-body" }
    news_article_type_id { NewsArticleType::PressRelease.id }
  end

  factory :draft_news_article, parent: :news_article, traits: [:draft]
  factory :submitted_news_article, parent: :news_article, traits: [:submitted]
  factory :rejected_news_article, parent: :news_article, traits: [:rejected]
  factory :published_news_article, parent: :news_article, traits: [:published] do
    first_published_at { 2.days.ago }
  end
  factory :deleted_news_article, parent: :news_article, traits: [:deleted]
  factory :superseded_news_article, parent: :news_article, traits: [:superseded]
  factory :scheduled_news_article, parent: :news_article, traits: [:scheduled]

  factory :published_news_story, parent: :published_news_article do
    news_article_type_id { NewsArticleType::NewsStory.id }
  end

  factory :news_article_news_story, parent: :news_article do
    news_article_type_id { NewsArticleType::NewsStory.id }
  end

  factory :news_article_press_release, parent: :news_article do
    news_article_type_id { NewsArticleType::PressRelease.id }
  end

  factory :news_article_government_response, parent: :news_article do
    news_article_type_id { NewsArticleType::GovernmentResponse.id }
  end

  factory :news_article_world_news_story, parent: :news_article do
    news_article_type_id { NewsArticleType::WorldNewsStory.id }

    transient do
      create_default_organisation { false }
    end

    after :build do |news_article, evaluator|
      if evaluator.worldwide_organisations.empty?
        document = build(:document)
        create(:worldwide_organisation, document:)
        news_article.worldwide_organisation_documents << document
      end
    end

    after :build do |news_article, evaluator|
      if evaluator.world_locations.empty?
        news_article.world_locations << build(:world_location)
      end
    end
  end
end
