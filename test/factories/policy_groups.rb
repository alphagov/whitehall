FactoryGirl.define do
  factory :policy_group do
    sequence(:email) { |n| "policy-group-#{n}@example.com" }
    name 'policy-group-name'
  end
end
