FactoryGirl.define do
  factory :worldwide_priority, class: WorldwidePriority, parent: :edition_with_organisations do
    title "worldwide-priority-title"
    body  "worldwide-priority-body"
    summary "worldwide-priority-summary"
  end

  factory :draft_worldwide_priority, parent: :worldwide_priority, traits: [:draft]
  factory :submitted_worldwide_priority, parent: :worldwide_priority, traits: [:submitted]
  factory :rejected_worldwide_priority, parent: :worldwide_priority, traits: [:rejected]
  factory :published_worldwide_priority, parent: :worldwide_priority, traits: [:published]
  factory :deleted_worldwide_priority, parent: :worldwide_priority, traits: [:deleted]
  factory :superseded_worldwide_priority, parent: :worldwide_priority, traits: [:superseded]
  factory :scheduled_worldwide_priority, parent: :worldwide_priority, traits: [:scheduled]
end
