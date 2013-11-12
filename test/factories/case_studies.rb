FactoryGirl.define do
  factory :case_study, class: CaseStudy, parent: :edition_with_organisations do
    title "case-study-title"
    summary "case-study-summary"
    body  "case-study-body"
  end

  factory :imported_case_study, parent: :case_study, traits: [:imported]
  factory :draft_case_study, parent: :case_study, traits: [:draft]
  factory :submitted_case_study, parent: :case_study, traits: [:submitted]
  factory :rejected_case_study, parent: :case_study, traits: [:rejected]
  factory :published_case_study, parent: :case_study, traits: [:published]
  factory :deleted_case_study, parent: :case_study, traits: [:deleted]
  factory :superseded_case_study, parent: :case_study, traits: [:superseded]
  factory :scheduled_case_study, parent: :case_study, traits: [:scheduled]
end
