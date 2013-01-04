FactoryGirl.define do
  factory :publication, class: Publication, parent: :edition do
    title "publication-title"
    body  "publication-body"
    summary "publication-summary"
    publication_date { 10.days.ago.to_date }
    publication_type_id { PublicationType::PolicyPaper.id }

    trait(:corporate) do
      publication_type_id { PublicationType::CorporateReport.id }
    end

    trait(:foi_release) do
      publication_type_id { PublicationType::FoiRelease.id }
    end

    trait(:transparency_data) do
      publication_type_id { PublicationType::TransparencyData.id }
    end
  end

  factory :imported_publication, parent: :publication, traits: [:imported]
  factory :draft_publication, parent: :publication, traits: [:draft]
  factory :submitted_publication, parent: :publication, traits: [:submitted]
  factory :rejected_publication, parent: :publication, traits: [:rejected]
  factory :published_publication, parent: :publication, traits: [:published]
  factory :deleted_publication, parent: :publication, traits: [:deleted]
  factory :archived_publication, parent: :publication, traits: [:archived]
  factory :scheduled_publication, parent: :publication, traits: [:scheduled]

  factory :draft_corporate_publication, parent: :publication, traits: [:draft, :corporate]
  factory :submitted_corporate_publication, parent: :publication, traits: [:submitted, :corporate]
  factory :published_corporate_publication, parent: :publication, traits: [:published, :corporate]
end
