FactoryGirl.define do
  factory :policy_topic_relation do
    association :policy_topic
    association :related_policy_topic, factory: :policy_topic
  end
end