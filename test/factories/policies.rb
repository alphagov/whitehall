FactoryGirl.define do
  factory :policy, class: Policy, parent: :edition, traits: [:with_organisations, :with_topics] do
    sequence(:title) { |index| "policy-title-#{index}" }
    body    "policy-body"
    summary "policy-summary"
  end

  factory :draft_policy, parent: :policy, traits: [:draft]
  factory :submitted_policy, parent: :policy, traits: [:submitted]
  factory :rejected_policy, parent: :policy, traits: [:rejected]
  factory :published_policy, parent: :policy, traits: [:published] do
    first_published_at  { 2.days.ago }
    public_timestamp { 2.days.ago }
  end
  factory :deleted_policy, parent: :policy, traits: [:deleted]
  factory :superseded_policy, parent: :policy, traits: [:superseded]
  factory :scheduled_policy, parent: :policy, traits: [:scheduled]
end
