FactoryGirl.define do
  factory :world_location_news_article, class: WorldLocationNewsArticle, parent: :edition do
    title "world-location-news-title"
    summary "world-location-news-summary"
    body  "world-location-news-body"
  end

  factory :imported_world_location_news_article, parent: :world_location_news_article, traits: [:imported]
  factory :draft_world_location_news_article, parent: :world_location_news_article, traits: [:draft]
  factory :submitted_world_location_news_article, parent: :world_location_news_article, traits: [:submitted]
  factory :rejected_world_location_news_article, parent: :world_location_news_article, traits: [:rejected]
  factory :published_world_location_news_article, parent: :world_location_news_article, traits: [:published] do
    first_published_at  { 2.days.ago }
  end
  factory :deleted_world_location_news_article, parent: :world_location_news_article, traits: [:deleted]
  factory :archived_world_location_news_article, parent: :world_location_news_article, traits: [:archived]
  factory :scheduled_world_location_news_article, parent: :world_location_news_article, traits: [:scheduled]
end
