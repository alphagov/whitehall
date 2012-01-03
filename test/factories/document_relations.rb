FactoryGirl.define do
  factory :document_relation do
    association :document
    association :document_identity, factory: :document_identity
  end
end