FactoryGirl.define do
  factory :classification do
    sequence(:name) { |index| "classification-#{index}" }
    description 'Classifcation description'
  end
end
