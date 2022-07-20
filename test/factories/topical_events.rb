FactoryBot.define do
  factory :topical_event do
    sequence(:name) { |index| "topical-event-#{index}" }
    summary { "Topical event summary" }
    description { "Topical event description" }
    trait :active do
      start_date { Time.zone.today - 1.month }
      end_date { Time.zone.today + 1.month }
    end
  end
end
