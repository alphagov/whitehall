FactoryGirl.define do
  factory :policy_team do
    sequence(:email) { |n| "policy-team-#{n}@example.com" }
  end
end
