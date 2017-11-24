FactoryBot.define do
  factory :classification_policy do
    association :classification, factory: :topic
  end
end
