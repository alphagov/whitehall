FactoryGirl.define do
  factory :world_location do
    name 'British Antarctic Territory'
    world_location_type WorldLocationType::OverseasTerritory
  end

  factory :country, parent: :world_location do
    name "France"
    world_location_type WorldLocationType::Country
  end

  factory :overseas_territory, parent: :world_location

  factory :international_delegation, parent: :world_location do
    name "United Nations"
    world_location_type WorldLocationType::InternationalDelegation
  end
end