FactoryGirl.define do
  factory :detailed_guide, class: DetailedGuide, parent: :edition do
    title "detailed-guide-title"
    body  "detailed-guide-body"
    primary_mainstream_category { FactoryGirl.build(:mainstream_category) }
  end

  factory :draft_detailed_guide, parent: :detailed_guide, traits: [:draft]
  factory :submitted_detailed_guide, parent: :detailed_guide, traits: [:submitted]
  factory :rejected_detailed_guide, parent: :detailed_guide, traits: [:rejected]
  factory :published_detailed_guide, parent: :detailed_guide, traits: [:published]
  factory :deleted_detailed_guide, parent: :detailed_guide, traits: [:deleted]
  factory :archived_detailed_guide, parent: :detailed_guide, traits: [:archived]
end
