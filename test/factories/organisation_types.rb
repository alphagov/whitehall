FactoryGirl.define do
  factory :organisation_type do
    sequence(:name) { |n| "Organisation Type #{n}" }
  end
end