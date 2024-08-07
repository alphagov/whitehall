FactoryBot.define do
  factory :world_location, traits: [:translated] do
    name { "British Antarctic Territory" }
    world_location_news { FactoryBot.build(:world_location_news) }
    world_location_type { "world_location" }

    trait(:with_worldwide_organisations) do
      after :create do |world_location, _evaluator|
        world_location.worldwide_organisations << FactoryBot.create(:worldwide_organisation)
      end
    end
  end

  factory :international_delegation, parent: :world_location do
    world_location_news { FactoryBot.build(:world_location_news) }
    name { "United Nations" }
    world_location_type { "international_delegation" }
  end
end
