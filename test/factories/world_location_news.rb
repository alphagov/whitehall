FactoryBot.define do
  factory :world_location_news, traits: [:translated] do
    content_id { SecureRandom.uuid }
    title { "UK and World Location" }
    mission_statement { "Our mission is to test world location news" }

    trait(:with_stubbed_slug) do
      after(:build) do |world_location_news|
        world_location_news.stubs(:slug).returns("/world/world-location/news")
      end
    end
  end

  factory :world_location_news_with_stubbed_slug, parent: :world_location_news, traits: [:with_stubbed_slug]
end
