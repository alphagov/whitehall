FactoryGirl.define do
  factory :publication, class: Publication, parent: :edition, traits: [:with_organisations, :with_topics] do
    sequence(:title) { |index| "publication-title-#{index}" }
    body  "publication-body"
    summary "publication-summary"
    publication_type_id { PublicationType::PolicyPaper.id }
    attachments { FactoryGirl.build_list :html_attachment, 1 }

    trait(:corporate) do
      publication_type_id { PublicationType::CorporateReport.id }
    end

    trait(:foi_release) do
      publication_type_id { PublicationType::FoiRelease.id }
    end

    trait(:transparency_data) do
      publication_type_id { PublicationType::TransparencyData.id }
    end

    trait(:statistics) do
      publication_type_id { PublicationType::Statistics.id }
    end

    trait(:national_statistics) do
      publication_type_id { PublicationType::NationalStatistics.id }
    end

    trait(:policy_paper) do
      publication_type_id { PublicationType::PolicyPaper.id }
    end

    trait(:guidance) do
      publication_type_id { PublicationType::Guidance.id }
    end

    trait(:with_command_paper) do
      attachments { [build(:file_attachment, unnumbered_command_paper: true)] }
      alternative_format_provider { build(:organisation, :with_alternative_format_contact_email) }
    end

    trait(:with_act_paper) do
      attachments { [build(:file_attachment, unnumbered_hoc_paper: true)] }
      alternative_format_provider { build(:organisation, :with_alternative_format_contact_email) }
    end

    ignore do
      relevant_to_local_government { false }
    end

    after(:build) do |object, evaluator|
      if evaluator.relevant_to_local_government
        object.related_policy_ids = [FactoryGirl.create(:published_policy, relevant_to_local_government: true)].map(&:id)
      end
    end
  end

  factory :imported_publication, parent: :publication, traits: [:imported]
  factory :draft_publication, parent: :publication, traits: [:draft]
  factory :submitted_publication, parent: :publication, traits: [:submitted]
  factory :rejected_publication, parent: :publication, traits: [:rejected]
  factory :published_publication, parent: :publication, traits: [:published]
  factory :deleted_publication, parent: :publication, traits: [:deleted]
  factory :superseded_publication, parent: :publication, traits: [:superseded]
  factory :scheduled_publication, parent: :publication, traits: [:scheduled]
  factory :unpublished_publication, parent: :publication, traits: [:draft, :unpublished]

  factory :draft_corporate_publication, parent: :publication, traits: [:draft, :corporate]
  factory :submitted_corporate_publication, parent: :publication, traits: [:submitted, :corporate]
  factory :published_corporate_publication, parent: :publication, traits: [:published, :corporate]

  factory :draft_policy_paper, parent: :publication, traits: [:draft, :policy_paper]
  factory :submitted_policy_paper, parent: :publication, traits: [:submitted, :policy_paper]
  factory :published_policy_paper, parent: :publication, traits: [:published, :policy_paper]

  factory :draft_statistics, parent: :publication, traits: [:draft, :statistics]
  factory :submitted_statistics, parent: :publication, traits: [:submitted, :statistics]
  factory :published_statistics, parent: :publication, traits: [:published, :statistics]

  factory :draft_national_statistics, parent: :publication, traits: [:draft, :national_statistics]
  factory :submitted_national_statistics, parent: :publication, traits: [:submitted, :national_statistics]
  factory :published_national_statistics, parent: :publication, traits: [:published, :national_statistics]
end
