FactoryBot.define do
  factory :call_for_evidence, class: CallForEvidence, parent: :edition, traits: %i[with_organisations] do
    title { "call-for-evidence-title" }
    body { "call-for-evidence-body" }
    opening_at { 1.day.ago }
    closing_at { 6.weeks.from_now }
    all_nation_applicability { true }
    transient do
      relevant_to_local_government { false }
    end

    trait(:with_html_attachment) do
      attachments { [FactoryBot.build(:html_attachment)] }
    end

    trait(:has_excluded_nations) do
      all_nation_applicability { false }
    end
  end

  factory :draft_call_for_evidence, parent: :call_for_evidence, traits: [:draft]
  factory :submitted_call_for_evidence, parent: :call_for_evidence, traits: [:submitted]
  factory :rejected_call_for_evidence, parent: :call_for_evidence, traits: [:rejected]
  factory :published_call_for_evidence, parent: :call_for_evidence, traits: [:published]
  factory :deleted_call_for_evidence, parent: :call_for_evidence, traits: [:deleted]
  factory :superseded_call_for_evidence, parent: :call_for_evidence, traits: [:superseded]
  factory :scheduled_call_for_evidence, parent: :call_for_evidence, traits: [:scheduled]

  factory :open_call_for_evidence, parent: :published_call_for_evidence do
    opening_at { 1.day.ago }
    closing_at { 1.day.from_now }
  end

  factory :closed_call_for_evidence, parent: :published_call_for_evidence do
    opening_at { 2.days.ago }
    closing_at { 1.day.ago }
  end

  factory :unopened_call_for_evidence, parent: :published_call_for_evidence do
    opening_at { 2.days.from_now }
    closing_at { 3.days.from_now }
  end

  factory :call_for_evidence_with_outcome, parent: :closed_call_for_evidence do
    outcome { create(:call_for_evidence_outcome) }
  end

  factory :call_for_evidence_with_outcome_file_attachment, parent: :closed_call_for_evidence do
    outcome { create(:call_for_evidence_outcome, :with_file_attachment) }
  end

  factory :call_for_evidence_with_outcome_html_attachment, parent: :closed_call_for_evidence do
    outcome { create(:call_for_evidence_outcome, :with_html_attachment) }
  end

  factory :call_for_evidence_with_public_feedback_html_attachment, parent: :closed_call_for_evidence do
    public_feedback { create(:consultation_public_feedback, :with_html_attachment) }
  end

  factory :call_for_evidence_with_excluded_nations, parent: :call_for_evidence, traits: [:has_excluded_nations]
  factory :published_call_for_evidence_with_excluded_nations, parent: :published_call_for_evidence, traits: [:has_excluded_nations]
end
