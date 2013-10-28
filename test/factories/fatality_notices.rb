FactoryGirl.define do
  factory :fatality_notice, class: FatalityNotice, parent: :edition do
    title "fatality-title"
    summary "fatality-summary"
    body  "fatality-body"
    roll_call_introduction "fatality-roll-call-introduction"
    operational_field
  end

  factory :draft_fatality_notice, parent: :fatality_notice, traits: [:draft]
  factory :submitted_fatality_notice, parent: :fatality_notice, traits: [:submitted]
  factory :rejected_fatality_notice, parent: :fatality_notice, traits: [:rejected]
  factory :published_fatality_notice, parent: :fatality_notice, traits: [:published]
  factory :deleted_fatality_notice, parent: :fatality_notice, traits: [:deleted]
  factory :superseded_fatality_notice, parent: :fatality_notice, traits: [:superseded]
  factory :scheduled_fatality_notice, parent: :fatality_notice, traits: [:scheduled]
end
