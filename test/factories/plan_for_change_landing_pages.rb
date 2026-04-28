FactoryBot.define do
  factory :plan_for_change_landing_page, class: PlanForChangeLandingPage, parent: :edition, traits: [:with_organisations] do
    title { "landing-page-title" }
    summary { "landing-page-summary" }
    body { "blocks:\n- type: govspeak\n  content: Hello!" }
  end

  factory :draft_plan_for_change_landing_page, parent: :plan_for_change_landing_page, traits: [:draft]
  factory :submitted_plan_for_change_landing_page, parent: :plan_for_change_landing_page, traits: [:submitted]
  factory :rejected_plan_for_change_landing_page, parent: :plan_for_change_landing_page, traits: [:rejected]
  factory :published_plan_for_change_landing_page, parent: :plan_for_change_landing_page, traits: [:published]
  factory :deleted_plan_for_change_landing_page, parent: :plan_for_change_landing_page, traits: [:deleted]
  factory :superseded_plan_for_change_landing_page, parent: :plan_for_change_landing_page, traits: [:superseded]
  factory :scheduled_plan_for_change_landing_page, parent: :plan_for_change_landing_page, traits: [:scheduled]
end
