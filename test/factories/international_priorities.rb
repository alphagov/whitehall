FactoryGirl.define do
  factory :international_priority, class: InternationalPriority, parent: :edition do
    title "international-priority-title"
    body  "international-priority-body"
    summary nil
  end

  factory :draft_international_priority, parent: :international_priority, traits: [:draft]
  factory :submitted_international_priority, parent: :international_priority, traits: [:submitted]
  factory :rejected_international_priority, parent: :international_priority, traits: [:rejected]
  factory :published_international_priority, parent: :international_priority, traits: [:published]
  factory :deleted_international_priority, parent: :international_priority, traits: [:deleted]
  factory :archived_international_priority, parent: :international_priority, traits: [:archived]
  factory :scheduled_international_priority, parent: :international_priority, traits: [:scheduled]
end
