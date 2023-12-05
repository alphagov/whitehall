FactoryBot.define do
  factory :edition_worldwide_organisation do
    edition
    association :legacy_worldwide_organisation, factory: :worldwide_organisation
  end
end
