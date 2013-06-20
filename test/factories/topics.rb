FactoryGirl.define do
  factory :topic do
    sequence(:name) { |index| "topic-#{index}" }
    description { Faker::Lorem.sentence }
  end
end
