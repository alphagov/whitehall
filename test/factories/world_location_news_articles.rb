FactoryGirl.define do
  factory :world_location_news_article, class: WorldLocationNewsArticle, parent: :edition, traits: [:with_topics] do
    title "world-location-news-title"
    summary "world-location-news-summary"
    body  "world-location-news-body"

    after :build do |news, evaluator|
      news.world_locations = [FactoryGirl.build(:world_location)] unless evaluator.world_locations.any?
      news.worldwide_organisations = [FactoryGirl.build(:worldwide_organisation)] unless evaluator.worldwide_organisations.any?
    end

  end

  factory :imported_world_location_news_article, parent: :world_location_news_article, traits: [:imported]
  factory :draft_world_location_news_article, parent: :world_location_news_article, traits: [:draft]
  factory :submitted_world_location_news_article, parent: :world_location_news_article, traits: [:submitted]
  factory :rejected_world_location_news_article, parent: :world_location_news_article, traits: [:rejected]
  factory :published_world_location_news_article, parent: :world_location_news_article, traits: [:published] do
    first_published_at  { 2.days.ago }
  end
  factory :deleted_world_location_news_article, parent: :world_location_news_article, traits: [:deleted]
  factory :superseded_world_location_news_article, parent: :world_location_news_article, traits: [:superseded]
  factory :scheduled_world_location_news_article, parent: :world_location_news_article, traits: [:scheduled]
end
