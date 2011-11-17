FactoryGirl.define do
  factory :policy, class: Policy, parent: :document do
    title "policy-title"
    body  "policy-body"
  end

  factory :draft_policy, parent: :policy, traits: [:draft]
  factory :submitted_policy, parent: :policy, traits: [:submitted]
  factory :rejected_policy, parent: :policy, traits: [:rejected]
  factory :published_policy, parent: :policy, traits: [:published]
  factory :deleted_policy, parent: :policy, traits: [:deleted]
  factory :archived_policy, parent: :policy, traits: [:archived]
end