FactoryBot.define do
  factory :travel_advice do
    sequence(:title) { |index| "travel-advice-#{index}" }
    base_path { "/foreign-travel-advice/name-of-country" }
  end
end
