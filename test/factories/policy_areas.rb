FactoryGirl.define do
  factory :policy_area do
    sequence(:name) { |index| "policy-area-#{index}" }
    description { Faker::Lorem.sentence }
  end
  factory :featured_policy_area, parent: :policy_area do
    featured true
  end
end