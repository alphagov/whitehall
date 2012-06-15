FactoryGirl.define do
  factory :policy_team do
    sequence(:email) { |n| "policy-team-#{n}@example.com" }
    name 'policy-team-name'
  end
end
