FactoryBot.define do
  factory :landing_page, class: LandingPage, parent: :edition, traits: [:with_organisations] do
    title { "landing-page-title" }
    summary { "landing-page-summary" }
    body { "blocks:\n- type: govspeak\n  content: Hello!" }
  end

  factory :draft_landing_page, parent: :landing_page, traits: [:draft]
  factory :submitted_landing_page, parent: :landing_page, traits: [:submitted]
  factory :rejected_landing_page, parent: :landing_page, traits: [:rejected]
  factory :published_landing_page, parent: :landing_page, traits: [:published]
  factory :deleted_landing_page, parent: :landing_page, traits: [:deleted]
  factory :superseded_landing_page, parent: :landing_page, traits: [:superseded]
  factory :scheduled_landing_page, parent: :landing_page, traits: [:scheduled]
end
