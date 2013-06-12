class GenericEdition < Edition
  class << self
    attr_accessor :translatable
  end
  def translatable?
    self.class.translatable
  end
end

Rails.application.routes.url_helpers.module_eval do
  def generic_edition_path(options = {})
    "/government/generic-editions/#{options[:id].to_param}"
  end

  def generic_edition_url(options = {})
    options[:host] + generic_edition_path(options)
  end
end

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
      major_change_published_at { 1.day.ago }
      force_published { false }
      published_major_version 1
      published_minor_version 0
      after :create do |edition|
        edition.refresh_index_if_required
      end
    end
    trait(:deleted) {
      state "draft"
      after :create do |edition|
        edition.delete!
      end
    }
    trait(:archived) {
      state "archived"
      after :create do |edition|
        edition.refresh_index_if_required
      end
    }
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
end
