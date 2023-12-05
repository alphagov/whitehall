FactoryBot.define do
  factory :sponsorship do
    organisation
    association :legacy_worldwide_organisation, factory: :worldwide_organisation
  end
end
