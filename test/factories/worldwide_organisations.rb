FactoryBot.define do
  factory :worldwide_organisation, traits: [:translated] do
    sequence(:name) { |index| "worldwide-organisation-#{index}" }

    trait(:with_office) do
      after :create do |organisation, _evaluator|
        FactoryBot.create(:worldwide_office, worldwide_organisation: organisation)
      end
    end

    trait(:with_sponsorships) do
      after :create do |organisation, _evaluator|
        FactoryBot.create(:sponsorship, worldwide_organisation: organisation)
      end
    end

    trait(:with_world_location) do
      after :create do |worldwide_organisation, _evaluator|
        worldwide_organisation.world_locations << FactoryBot.create(:world_location)
      end
    end
  end
end
