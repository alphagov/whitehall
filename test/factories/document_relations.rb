FactoryGirl.define do
  factory :document_relation do
    association :document
    association :doc_identity, factory: :doc_identity
  end
end
