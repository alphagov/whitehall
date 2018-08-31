FactoryBot.define do
  factory :detailed_guide, class: DetailedGuide, parent: :edition, traits: %i[with_organisations with_topics] do
    sequence(:title) { |index| "detailed-guide-title-#{index}" }
    body { "detailed-guide-body" }
  end

  factory :draft_detailed_guide, parent: :detailed_guide, traits: [:draft]
  factory :submitted_detailed_guide, parent: :detailed_guide, traits: [:submitted]
  factory :rejected_detailed_guide, parent: :detailed_guide, traits: [:rejected]
  factory :published_detailed_guide, parent: :detailed_guide, traits: [:published]
  factory :deleted_detailed_guide, parent: :detailed_guide, traits: [:deleted]
  factory :superseded_detailed_guide, parent: :detailed_guide, traits: [:superseded]
  factory :scheduled_detailed_guide, parent: :detailed_guide, traits: [:scheduled]
end
