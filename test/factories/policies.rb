FactoryGirl.define do
  factory :policy do
    author
    title "policy-title"
    body  "policy-body"
  end

  factory :rejected_policy, parent: :policy do
    state "rejected"
  end

  factory :published_policy, parent: :policy do
    state "published"
  end

  factory :draft_policy, parent: :policy do
    state "draft"
  end

  factory :deleted_policy, parent: :policy do
    state "deleted"
  end

  factory :archived_policy, parent: :policy do
    state "archived"
  end

  factory :submitted_policy, parent: :policy do
    state "submitted"
  end
end