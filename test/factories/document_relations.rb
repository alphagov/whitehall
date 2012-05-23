FactoryGirl.define do
  factory :document_relation do
    association :edition
    association :doc_identity, factory: :doc_identity
  end
end
