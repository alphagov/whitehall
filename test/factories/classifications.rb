FactoryGirl.define do
  factory :classification do
    sequence(:name) { |index| "classification-#{index}" }
    description { Faker::Lorem.sentence }
  end
end
