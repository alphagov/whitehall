FactoryGirl.define do
  factory :consultation, class: Consultation, parent: :document do
    title "consultation-title"
    body  "consultation-body"
    opening_on { 1.day.ago }
    closing_on { 6.weeks.from_now }
  end

  factory :draft_consultation, parent: :consultation, traits: [:draft]
  factory :submitted_consultation, parent: :consultation, traits: [:submitted]
  factory :rejected_consultation, parent: :consultation, traits: [:rejected]
  factory :published_consultation, parent: :consultation, traits: [:published]
  factory :deleted_consultation, parent: :consultation, traits: [:deleted]
  factory :archived_consultation, parent: :consultation, traits: [:archived]

  factory :featured_consultation, parent: :consultation, traits: [:published, :featured]
end