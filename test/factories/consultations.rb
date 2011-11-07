FactoryGirl.define do
  factory :consultation do
    author
    title "consultation-title"
    body  "consultation-body"
    opening_on 1.day.ago
    closing_on 6.weeks.from_now
  end

  factory :draft_consultation, parent: :consultation do
    state "draft"
  end

  factory :submitted_consultation, parent: :consultation do
    state "submitted"
  end

  factory :rejected_consultation, parent: :consultation do
    state "rejected"
  end

  factory :published_consultation, parent: :consultation do
    state "published"
  end

  factory :archived_consultation, parent: :consultation do
    state "archived"
  end
end