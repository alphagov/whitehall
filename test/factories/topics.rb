FactoryGirl.define do
  factory :topic do
    sequence(:name) { |index| "topic-#{index}" }
    description 'Topic description'
  end
end
