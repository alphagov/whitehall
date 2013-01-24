FactoryGirl.define do
  factory :policy_group_attachment do
    association :policy_group, factory: :policy_advisory_group
    attachment
  end
end
