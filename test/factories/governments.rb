FactoryGirl.define do
  factory :government do
    sequence(:name) { |index| "Government #{index}" }
  end
end
