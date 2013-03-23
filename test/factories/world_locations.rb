FactoryGirl.define do
  factory :world_location, traits: [:translated] do
    name 'British Antarctic Territory'
    world_location_type WorldLocationType::WorldLocation
  end

  factory :international_delegation, parent: :world_location do
    name "United Nations"
    world_location_type WorldLocationType::InternationalDelegation
  end
end
