FactoryGirl.define do
  factory :topic do
    sequence(:name) { |index| "topic-#{index}" }
    description { Faker::Lorem.sentence }
  end
  factory :featured_topic, parent: :topic do
    featured true
  end
end