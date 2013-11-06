FactoryGirl.define do
  factory :news_article, class: NewsArticle, parent: :edition do
    title "news-title"
    summary "news-summary"
    body  "news-body"
    news_article_type_id { NewsArticleType::PressRelease.id }
    ignore do
      relevant_to_local_government { false }
    end

    after(:build) do |object, evaluator|
      if evaluator.relevant_to_local_government
        object.related_documents = [FactoryGirl.create(:published_policy, :with_document, relevant_to_local_government: true)].map(&:document)
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

end
