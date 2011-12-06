FactoryGirl.define do
  factory :policy_area_relation do
    association :policy_area
    association :related_policy_area, factory: :policy_area
  end
end