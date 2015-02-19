FactoryGirl.define do
  factory :government do
    sequence(:name) { |index| "Government #{index}" }
    start_date "2010-05-06"
  end
end
