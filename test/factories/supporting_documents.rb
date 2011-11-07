FactoryGirl.define do
  factory :supporting_document do
    title "Something Supportive"
    body "Some supporting information"
    association :document, factory: :policy
  end
end