require_relative '../support/generic_edition'

FactoryGirl.define do
  factory :edition, class: GenericEdition, traits: [:translated] do
    ignore do
      organisations { [] }
      create_default_organisation { true }
      supporting_organisations { [] }
      lead_organisations { organisations }
    end
    creator
    sequence(:title) { |index| "edition-title-#{index}" }
    body "edition-body"
    change_note "change-note"
    summary 'edition-summary'

    after :build do |edition, evaluator|
      edition.skip_virus_status_check = true

      if evaluator.lead_organisations.empty? && evaluator.create_default_organisation
        edition.edition_organisations.build(edition: edition,
                                            organisation: FactoryGirl.build(:organisation),
                                            lead_ordering: 1,
                                            lead: true)
      end
      Array.wrap(evaluator.lead_organisations).each.with_index do |org, idx|
        edition.edition_organisations.build(edition: edition,
                                            organisation: org,
                                            lead_ordering: idx+1,
                                            lead: true)
      end
      Array.wrap(evaluator.supporting_organisations).each do |org|
        edition.edition_organisations.build(edition: edition,
                                            organisation: org,
                                            lead: false)
      end
    end

    trait(:imported) do
      state "imported"
      first_published_at { 1.year.ago }
    end
    trait(:draft) { state "draft" }
    trait(:submitted) { state "submitted" }
    trait(:rejected) { state "rejected" }
    trait(:published) do
      state "published"
      first_published_at { 2.days.ago }
      major_change_published_at { 1.day.ago }
      force_published { false }
      published_major_version 1
      published_minor_version 0
      after :create do |edition|
        edition.refresh_index_if_required
      end
    end
    trait(:deleted) {
      state "deleted"
    }
    trait(:archived) {
      state "archived"
      after :create do |edition|
        edition.refresh_index_if_required
      end
    }
    trait(:superseded) {
      state "superseded"
    }
    trait(:featured) { featured true }
    trait(:scheduled) {
      state "scheduled"
      scheduled_publication 7.days.from_now
    }
    trait(:access_limited) { access_limited true }

    trait(:with_alternative_format_provider) do
      association :alternative_format_provider, factory: :organisation_with_alternative_format_contact_email
    end

    trait(:with_file_attachment) do
      association :alternative_format_provider, factory: :organisation_with_alternative_format_contact_email
      attachments { FactoryGirl.build_list :file_attachment, 1 }
      after :build do |edition, evaluator|
        VirusScanHelpers.simulate_virus_scan(edition.attachments.first.attachment_data.file)
      end
    end

    trait(:with_html_attachment) do
      association :alternative_format_provider, factory: :organisation_with_alternative_format_contact_email
      attachments { FactoryGirl.build_list :html_attachment, 1 }
    end

    trait(:with_file_attachment_not_scanned) do
      association :alternative_format_provider, factory: :organisation_with_alternative_format_contact_email
      attachments { FactoryGirl.build_list :file_attachment, 1 }
    end

    trait(:with_document) do
      document
    end

    trait(:unpublished) do
      unpublishing
    end
  end

  factory :imported_edition, parent: :edition, traits: [:imported]
  factory :draft_edition, parent: :edition, traits: [:draft]
  factory :submitted_edition, parent: :edition, traits: [:submitted]
  factory :rejected_edition, parent: :edition, traits: [:rejected]
  factory :published_edition, parent: :edition, traits: [:published]
  factory :deleted_edition, parent: :edition, traits: [:deleted]
  factory :archived_edition, parent: :edition, traits: [:archived]
  factory :scheduled_edition, parent: :edition, traits: [:scheduled]
  factory :unpublished_edition, parent: :edition, traits: [:draft, :unpublished]
  factory :protected_edition, parent: :edition, traits: [:access_limited]
end
