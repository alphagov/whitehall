FactoryGirl.define do
  factory :worldwide_organisation, traits: [:translated] do
    sequence(:name) { |index| "worldwide-organisation-#{index}" }
    summary "summary"
    description "description"
  end
end
