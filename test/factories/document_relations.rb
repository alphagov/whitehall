FactoryGirl.define do
  factory :document_relation do
    association :document
    association :related_document, factory: :document
  end
end