FactoryGirl.define do
  factory :news_article, class: NewsArticle, parent: :edition, traits: [:with_organisations, :with_topics] do
    title "news-title"
    summary "news-summary"
    body  "news-body"
    news_article_type_id { NewsArticleType::PressRelease.id }
    transient do
      relevant_to_local_government { false }
    end

    after(:build) do |news_article, evaluator|
      if evaluator.relevant_to_local_government
        document = create(
          :published_policy,
          :with_document,
          relevant_to_local_government: true
        ).document
        news_article.related_documents << document
      end
    end
  end

  factory :imported_news_article, parent: :news_article, traits: [:imported]
  factory :draft_news_article, parent: :news_article, traits: [:draft]
  factory :submitted_news_article, parent: :news_article, traits: [:submitted]
  factory :rejected_news_article, parent: :news_article, traits: [:rejected]
  factory :published_news_article, parent: :news_article, traits: [:published] do
    first_published_at  { 2.days.ago }
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
        news_article.worldwide_organisations << build(:worldwide_organisation)
      end
    end

    after :build do |news_article, evaluator|
      if evaluator.world_locations.empty?
        news_article.world_locations << build(:world_location)
      end
    end
  end
end
