FactoryGirl.define do
  factory :topical_event do
    sequence(:name) { |index| "topical-event-#{index}" }
    description { Faker::Lorem.sentence }
  end
end
