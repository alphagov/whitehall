FactoryGirl.define do
  factory :organisation do
    sequence(:name) { |index| "organisation-#{index}" }
    organisation_type
  end
end