GenericEdition = Class.new(Edition)

Rails.application.routes.url_helpers.module_eval do
  def generic_edition_path(options = {})
    "/government/generic-editions/#{options[:id].to_param}"
  end

  def generic_edition_url(options = {})
    options[:host] + generic_edition_path(options)
  end

  def admin_generic_edition_path(edition)
    "/government/admin/generic-editions/#{edition.to_param}"
  end

  def admin_generic_edition_url(edition)
    "http://test.host" + admin_generic_edition_path(edition)
  end

  def edit_admin_generic_edition_path(edition)
    "/government/admin/generic-editions/#{edition.to_param}/edit"
  end

  def admin_generic_edition_editorial_remarks_path(*args)
    admin_edition_editorial_remarks_path(*args)
  end
end

FactoryGirl.define do
  factory :edition, class: GenericEdition do
    ignore do
      organisations { [] }
      create_default_organisation { true }
      supporting_organisations { [] }
      lead_organisations { organisations }
    end
    creator
    title "edition-title"
    body "edition-body"
    change_note "change-note"
    summary 'edition-summary'

    after :build do |edition, evaluator|
      if evaluator.lead_organisations.empty? && evaluator.create_default_organisation
        edition.lead_edition_organisations.build(edition: edition,
                                                 organisation: FactoryGirl.build(:organisation),
                                                 lead_ordering: 1)
      end
      Array.wrap(evaluator.lead_organisations).each.with_index do |org, idx|
        edition.lead_edition_organisations.build(edition: edition,
                                                 organisation: org,
                                                 lead_ordering: idx+1)
      end
      Array.wrap(evaluator.supporting_organisations).each do |org|
        edition.supporting_edition_organisations.build(edition: edition,
                                                       organisation: org)
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
      major_change_published_at { 1.day.ago }
      force_published { false }
      published_major_version 1
      published_minor_version 0
    end
    trait(:deleted) {
      state "draft"
      after :create do |edition|
        edition.delete!
      end
    }
    trait(:archived) { state "archived" }
    trait(:featured) { featured true }
    trait(:scheduled) {
      state "scheduled"
      scheduled_publication 7.days.from_now
    }

    trait(:with_alternative_format_provider) do
      association :alternative_format_provider, factory: :organisation_with_alternative_format_contact_email
    end

    trait(:with_attachment) do
      association :alternative_format_provider, factory: :organisation_with_alternative_format_contact_email
      attachments { FactoryGirl.build_list :attachment, 1 }
    end

    trait(:with_document) do
      document
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
end
