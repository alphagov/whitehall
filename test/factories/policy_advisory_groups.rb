FactoryGirl.define do
  factory :policy_advisory_group do
    sequence(:email) { |n| "policy-advisory-group-#{n}@example.com" }
    name 'policy-advisory-group-name'
  end
end
