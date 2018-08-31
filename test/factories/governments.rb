FactoryBot.define do
  factory :government do
    sequence(:name) { |index| "Government #{index}" }
    start_date { "2010-05-06" }
  end

  factory :current_government, parent: :government do
    start_date { 2.years.ago }
  end

  factory :previous_government, parent: :government do
    start_date { 6.years.ago }
    end_date { 2.years.ago }
  end
end
