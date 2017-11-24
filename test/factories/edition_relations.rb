FactoryBot.define do
  factory :edition_relation do
    association :edition
    association :document, factory: :document
  end
end
