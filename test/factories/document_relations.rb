FactoryGirl.define do
  factory :document_relation do
    association :document
    association :policy, factory: :policy
  end
end