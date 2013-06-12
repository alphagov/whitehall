FactoryGirl.define do
  factory :person, traits: [:translated] do
    sequence(:forename) { |index| "George #{index}" }
  end
end
