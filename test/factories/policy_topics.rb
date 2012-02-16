FactoryGirl.define do
  factory :policy_topic do
    sequence(:name) { |index| "policy-topic-#{index}" }
    description { Faker::Lorem.sentence }
  end
  factory :featured_policy_topic, parent: :policy_topic do
    featured true
  end
end