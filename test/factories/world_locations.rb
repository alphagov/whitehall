FactoryBot.define do
  factory :world_location, traits: [:translated] do
    name { "British Antarctic Territory" }
    world_location_type { WorldLocationType::WorldLocation }
    title { "British Antarctic Territory and the UK" }

    trait(:with_worldwide_organisations) do
      after :create do |world_location, _evaluator|
        world_location.worldwide_organisations << FactoryBot.create(:worldwide_organisation, :with_sponsorships)
      end
    end
  end

  factory :international_delegation, parent: :world_location do
    name { "United Nations" }
    world_location_type { WorldLocationType::InternationalDelegation }
  end
end
