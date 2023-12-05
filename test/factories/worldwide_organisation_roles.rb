FactoryBot.define do
  factory :worldwide_organisation_role do
    association :legacy_worldwide_organisation, factory: :worldwide_organisation
    role
  end
end
