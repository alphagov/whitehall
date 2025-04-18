FactoryBot.define do
  factory :publication, class: Publication, parent: :edition, traits: %i[with_organisations] do
    sequence(:title) { |index| "publication-title-#{index}" }
    body { "publication-body" }
    summary { "publication-summary" }
    publication_type_id { PublicationType::PolicyPaper.id }
    attachments { FactoryBot.build_list :html_attachment, 1 }
    all_nation_applicability { true }

    trait(:has_excluded_nations) do
      all_nation_applicability { false }
    end

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
      publication_type_id { PublicationType::OfficialStatistics.id }
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

    trait(:with_alternative_format_provider) do
      alternative_format_provider { build(:organisation, :with_alternative_format_contact_email) }
    end

    trait(:with_command_paper) do
      attachments { [build(:file_attachment, unnumbered_command_paper: true)] }
      alternative_format_provider { build(:organisation, :with_alternative_format_contact_email) }
    end

    trait(:with_act_paper) do
      attachments { [build(:file_attachment, unnumbered_hoc_paper: true)] }
      alternative_format_provider { build(:organisation, :with_alternative_format_contact_email) }
    end

    trait(:with_external_attachment) do
      attachments { [build(:external_attachment)] }
    end
  end

  factory :draft_publication, parent: :publication, traits: [:draft]
  factory :submitted_publication, parent: :publication, traits: [:submitted]
  factory :rejected_publication, parent: :publication, traits: [:rejected]
  factory :published_publication, parent: :publication, traits: [:published]
  factory :deleted_publication, parent: :publication, traits: [:deleted]
  factory :superseded_publication, parent: :publication, traits: [:superseded]
  factory :scheduled_publication, parent: :publication, traits: [:scheduled]
  factory :unpublished_publication, parent: :publication, traits: [:unpublished]
  factory :unpublished_publication_in_error_no_redirect,
          parent: :publication,
          traits: %i[published_in_error_no_redirect]
  factory :unpublished_publication_in_error_redirect,
          parent: :publication,
          traits: %i[published_in_error_redirect]
  factory :unpublished_publication_consolidated,
          parent: :publication,
          traits: %i[consolidated_redirect]
  factory :withdrawn_publication, parent: :publication, traits: [:withdrawn]

  factory :published_publication_with_excluded_nations, parent: :published_publication, traits: [:has_excluded_nations]
  factory :draft_publication_with_excluded_nations, parent: :draft_publication, traits: [:has_excluded_nations]

  factory :draft_corporate_publication, parent: :publication, traits: %i[draft corporate]
  factory :submitted_corporate_publication, parent: :publication, traits: %i[submitted corporate]
  factory :published_corporate_publication, parent: :publication, traits: %i[published corporate]

  factory :draft_policy_paper, parent: :publication, traits: %i[draft policy_paper]
  factory :submitted_policy_paper, parent: :publication, traits: %i[submitted policy_paper]
  factory :published_policy_paper, parent: :publication, traits: %i[published policy_paper]

  factory :draft_statistics, parent: :publication, traits: %i[draft statistics]
  factory :submitted_statistics, parent: :publication, traits: %i[submitted statistics]
  factory :published_statistics, parent: :publication, traits: %i[published statistics]
  factory :superseded_statistics, parent: :publication, traits: %i[superseded statistics]

  factory :published_guidance, parent: :publication, traits: %i[published guidance]

  factory :draft_national_statistics, parent: :publication, traits: %i[draft national_statistics]
  factory :submitted_national_statistics, parent: :publication, traits: %i[submitted national_statistics]
  factory :published_national_statistics, parent: :publication, traits: %i[published national_statistics]
end
