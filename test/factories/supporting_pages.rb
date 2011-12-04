FactoryGirl.define do
  factory :supporting_page do
    title "Something Supportive"
    body "Some supporting information"
    association :document, factory: :policy
  end
end