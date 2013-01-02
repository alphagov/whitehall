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
    creator
    title "edition-title"
    body "edition-body"
    change_note "change-note"
    summary 'edition-summary'

    after :build do |edition, evaluator|
      edition.organisations = FactoryGirl.build_list(:organisation, 1) unless evaluator.organisations.any?
    end

    trait(:imported) { state "imported" }
    trait(:draft) { state "draft" }
    trait(:submitted) { state "submitted" }
    trait(:rejected) { state "rejected" }
    trait(:published) do
      state "published"
      published_at { 1.day.ago }
      first_published_at { published_at }
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
