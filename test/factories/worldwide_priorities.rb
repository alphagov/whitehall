FactoryGirl.define do
  factory :worldwide_priority, class: WorldwidePriority, parent: :edition do
    title "worldwide-priority-title"
    body  "worldwide-priority-body"
    summary "worldwide-priority-summary"
  end

  factory :draft_worldwide_priority, parent: :worldwide_priority, traits: [:draft]
  factory :submitted_worldwide_priority, parent: :worldwide_priority, traits: [:submitted]
  factory :rejected_worldwide_priority, parent: :worldwide_priority, traits: [:rejected]
  factory :published_worldwide_priority, parent: :worldwide_priority, traits: [:published] do
    first_published_at { 2.days.ago }
  end
  factory :deleted_worldwide_priority, parent: :worldwide_priority, traits: [:deleted]
  factory :archived_worldwide_priority, parent: :worldwide_priority, traits: [:archived]
  factory :scheduled_worldwide_priority, parent: :worldwide_priority, traits: [:scheduled]
end
