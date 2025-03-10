FactoryBot.define do
  factory :consultation, class: Consultation, parent: :edition, traits: %i[with_organisations] do
    title { "consultation-title" }
    body { "consultation-body" }
    opening_at { 1.day.ago }
    closing_at { 6.weeks.from_now }
    read_consultation_principles { true }
    all_nation_applicability { true }

    trait(:with_html_attachment) do
      attachments { [FactoryBot.build(:html_attachment)] }
    end

    trait(:has_excluded_nations) do
      all_nation_applicability { false }
    end
  end

  factory :draft_consultation, parent: :consultation, traits: [:draft]
  factory :submitted_consultation, parent: :consultation, traits: [:submitted]
  factory :rejected_consultation, parent: :consultation, traits: [:rejected]
  factory :published_consultation, parent: :consultation, traits: [:published]
  factory :deleted_consultation, parent: :consultation, traits: [:deleted]
  factory :superseded_consultation, parent: :consultation, traits: [:superseded]
  factory :scheduled_consultation, parent: :consultation, traits: [:scheduled]

  factory :open_consultation, parent: :published_consultation do
    opening_at { 1.day.ago }
    closing_at { 1.day.from_now }
  end

  factory :closed_consultation, parent: :published_consultation do
    opening_at { 2.days.ago }
    closing_at { 1.day.ago }
  end

  factory :unopened_consultation, parent: :published_consultation do
    opening_at { 2.days.from_now }
    closing_at { 3.days.from_now }
  end

  factory :consultation_with_outcome, parent: :closed_consultation do
    outcome { create(:consultation_outcome) }
  end

  factory :consultation_with_outcome_file_attachment, parent: :closed_consultation do
    outcome { create(:consultation_outcome, :with_file_attachment) }
  end

  factory :consultation_with_outcome_html_attachment, parent: :closed_consultation do
    outcome { create(:consultation_outcome, :with_html_attachment) }
  end

  factory :consultation_with_public_feedback_html_attachment, parent: :closed_consultation do
    public_feedback { create(:consultation_public_feedback, :with_html_attachment) }
  end

  factory :consultation_with_excluded_nations, parent: :consultation, traits: [:has_excluded_nations]
  factory :published_consultation_with_excluded_nations, parent: :published_consultation, traits: [:has_excluded_nations]
end
