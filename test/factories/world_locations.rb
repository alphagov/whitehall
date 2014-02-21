FactoryGirl.define do
  factory :world_location, traits: [:translated] do
    name 'British Antarctic Territory'
    world_location_type WorldLocationType::WorldLocation

    trait(:with_worldwide_organisations) {
      after :create do |world_location, evaluator|
        world_location.worldwide_organisations << FactoryGirl.create(:worldwide_organisation, :with_sponsorships)
      end
    }
  end

  factory :international_delegation, parent: :world_location do
    name "United Nations"
    world_location_type WorldLocationType::InternationalDelegation
  end
end
