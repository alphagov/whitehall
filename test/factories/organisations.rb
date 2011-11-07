FactoryGirl.define do
  factory :organisation do
    sequence(:name) { |index| "organisation-#{index}" }
  end
end