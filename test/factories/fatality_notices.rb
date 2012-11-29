FactoryGirl.define do
  factory :fatality_notice, class: FatalityNotice, parent: :edition do
    title "news-title"
    summary "news-summary"
    body  "news-body"
  end

  factory :draft_fatality_notice, parent: :fatality_notice, traits: [:draft]
  factory :submitted_fatality_notice, parent: :fatality_notice, traits: [:submitted]
  factory :rejected_fatality_notice, parent: :fatality_notice, traits: [:rejected]
  factory :published_fatality_notice, parent: :fatality_notice, traits: [:published]
  factory :deleted_fatality_notice, parent: :fatality_notice, traits: [:deleted]
  factory :archived_fatality_notice, parent: :fatality_notice, traits: [:archived]
  factory :scheduled_fatality_notice, parent: :fatality_notice, traits: [:scheduled]
end
