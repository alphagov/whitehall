FactoryGirl.define do
  factory :topic do
    sequence(:name) { |index| "topic-#{index}" }
    description 'Topic description'

    trait :with_classification_policies do
      classification_policies { create_list(:classification_policy, 1) }
    end
  end
end
