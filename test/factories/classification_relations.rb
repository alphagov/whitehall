FactoryBot.define do
  factory :classification_relation do
    association :classification, factory: :topic
    association :related_classification, factory: :topic
  end
end
