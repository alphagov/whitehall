FactoryGirl.define do
  factory :topical_event do
    sequence(:name) { |index| "topical-event-#{index}" }
    description { Faker::Lorem.sentence }
    trait :active do
      start_date Date.today - 1.month
      end_date Date.today + 1.month
    end
  end
end
