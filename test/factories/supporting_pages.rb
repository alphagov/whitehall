FactoryGirl.define do
  factory :supporting_page do
    title "Something Supportive"
    body "Some supporting information"
    association :edition, factory: :policy
  end
end