FactoryGirl.define do
  factory :topic_relation do
    association :topic
    association :related_topic, factory: :topic
  end
end