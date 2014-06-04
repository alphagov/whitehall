FactoryGirl.define do
  factory :featured_item do
    item { FactoryGirl.build(:topic) }
    started_at { 3.days.ago }
    featured_topics_and_policies_list
  end
  factory :featured_topic_item, parent: :featured_item
  factory :featured_policy_item, parent: :featured_item do
    item { FactoryGirl.create(:policy, :with_document).document }
  end
end
