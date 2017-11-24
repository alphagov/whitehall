FactoryBot.define do
  factory :classification do
    sequence(:name) { |index| "classification-#{index}" }
    description 'Classification description'
  end
end
