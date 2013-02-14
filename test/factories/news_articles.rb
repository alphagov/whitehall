FactoryGirl.define do
  factory :news_article, class: NewsArticle, parent: :edition do
    title "news-title"
    summary "news-summary"
    body  "news-body"
    news_article_type {NewsArticleType::PressRelease}
  end

  factory :imported_news_article, parent: :news_article, traits: [:imported]
  factory :draft_news_article, parent: :news_article, traits: [:draft]
  factory :submitted_news_article, parent: :news_article, traits: [:submitted]
  factory :rejected_news_article, parent: :news_article, traits: [:rejected]
  factory :published_news_article, parent: :news_article, traits: [:published] do
    first_published_at  { 2.days.ago }
  end
  factory :deleted_news_article, parent: :news_article, traits: [:deleted]
  factory :archived_news_article, parent: :news_article, traits: [:archived]
  factory :scheduled_news_article, parent: :news_article, traits: [:scheduled]
end
