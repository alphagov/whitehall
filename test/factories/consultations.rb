FactoryGirl.define do
  factory :consultation, class: Consultation, parent: :edition do
    title "consultation-title"
    body  "consultation-body"
    opening_at { 1.day.ago }
    closing_at { 6.weeks.from_now }
    ignore do
      relevant_to_local_government { false }
    end

    after(:build) do |object, evaluator|
      if evaluator.relevant_to_local_government
        object.related_policy_ids = [FactoryGirl.create(:published_policy, relevant_to_local_government: true)].map(&:id)
      end
    end
  end

  factory :imported_consultation, parent: :consultation, traits: [:imported]
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

  factory :consultation_with_outcome, parent: :closed_consultation do
    outcome { create(:consultation_outcome) }
  end
end
