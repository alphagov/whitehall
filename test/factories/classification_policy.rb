FactoryBot.define do
  factory :classification_policy do
    association :classification, factory: :topical_event
  end
end
