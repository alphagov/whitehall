require_relative '../support/generic_edition'

FactoryBot.define do
  factory :edition, class: GenericEdition, traits: [:translated] do
    creator
    sequence(:title) { |index| "edition-title-#{index}" }
    body { "edition-body" }
    change_note { "change-note" }
    summary { 'edition-summary' }
    previously_published { false }

    trait(:with_organisations) do
      transient do
        organisations { [] }
        create_default_organisation { true }
        supporting_organisations { [] }
        lead_organisations { organisations }
      end
      after :build do |edition, evaluator|
        if evaluator.lead_organisations.empty? && evaluator.create_default_organisation
          edition.edition_organisations.build(edition: edition,
                                              organisation: FactoryBot.build(:organisation),
                                              lead_ordering: 1,
                                              lead: true)
        end
        Array.wrap(evaluator.lead_organisations).each.with_index do |org, idx|
          edition.edition_organisations.build(edition: edition,
                                              organisation: org,
                                              lead_ordering: idx + 1,
                                              lead: true)
        end
        Array.wrap(evaluator.supporting_organisations).each do |org|
          edition.edition_organisations.build(edition: edition,
                                              organisation: org,
                                              lead: false)
        end
      end
    end

    trait(:with_topics) do
      after :build do |edition, evaluator|
        if evaluator.topics.empty?
          edition.classification_memberships.build(edition: edition,
                                                   classification: build(:topic))
        end
      end
    end

    trait(:with_topical_events) do
      after :build do |edition, evaluator|
        if evaluator.topical_events.empty?
          edition.classification_memberships.build(edition: edition,
                                                   classification: build(:topical_event))
        end
      end
    end

    trait(:with_policy_edition) do
      transient do
        policy_content_id { '' }
      end
      after :create do |edition, evaluator|
        EditionPolicy.create(edition_id: edition.id, policy_content_id: evaluator.policy_content_id)
      end
    end

    trait(:imported) do
      state { "imported" }
      first_published_at { 1.year.ago }
    end

    trait(:draft) { state { "draft" } }

    trait(:submitted) do
      transient do
        submitter { nil }
      end
      state { "submitted" }
      after :create do |edition, evaluator|
        edition.versions.first.update(event: 'create', state: 'draft')
        submitter = evaluator.submitter.present? ? evaluator.submitter : edition.creator
        edition.versions.create! event: 'update', whodunnit: submitter.id, state: 'submitted'
      end
    end

    trait(:rejected) { state { "rejected" } }

    trait(:published) do
      state { "published" }
      first_published_at { 2.days.ago }
      major_change_published_at { 1.day.ago }
      force_published { false }
      published_major_version { 1 }
      published_minor_version { 0 }
      after :create, &:refresh_index_if_required
    end

    trait(:deleted) { state { "deleted" } }

    trait(:superseded) { state { "superseded" } }

    trait(:featured) { featured { true } }

    trait(:scheduled) do
      state { "scheduled" }
      scheduled_publication { 7.days.from_now }
    end

    trait(:access_limited) { access_limited { true } }

    trait(:with_alternative_format_provider) do
      association :alternative_format_provider, factory: :organisation_with_alternative_format_contact_email
    end

    trait(:with_file_attachment) do
      association :alternative_format_provider, factory: :organisation_with_alternative_format_contact_email
      attachments { FactoryBot.build_list :file_attachment, 1 }
    end

    trait(:with_html_attachment) do
      association :alternative_format_provider, factory: :organisation_with_alternative_format_contact_email
      attachments { FactoryBot.build_list :html_attachment, 1 }
    end

    trait(:with_file_attachment_not_scanned) do
      association :alternative_format_provider, factory: :organisation_with_alternative_format_contact_email
      attachments { FactoryBot.build_list :file_attachment, 1 }
    end

    trait(:with_document) do
      document
    end

    trait(:unpublished) do
      after(:create) do |edition|
        edition.unpublishing = build(:unpublishing, edition: edition)
      end
    end

    trait(:published_in_error_redirect) do
      after(:create) do |edition|
        edition.unpublishing = build(:published_in_error_redirect_unpublishing, edition: edition)
      end
    end

    trait(:published_in_error_no_redirect) do
      after(:create) do |edition|
        edition.unpublishing = build(:published_in_error_no_redirect_unpublishing, edition: edition)
      end
    end

    trait(:consolidated_redirect) do
      after(:create) do |edition|
        edition.unpublishing = build(:consolidated_unpublishing, edition: edition)
      end
    end

    trait(:withdrawn) do
      state { "withdrawn" }
      after(:create) do |edition|
        edition.unpublishing = build(:withdrawn_unpublishing, edition: edition)
      end
    end
  end

  factory :announcement, parent: :edition, class: Announcement, traits: %i[with_organisations with_topics]

  factory :edition_with_document, parent: :edition, traits: [:with_document]
  factory :imported_edition, parent: :edition, traits: [:imported]
  factory :draft_edition, parent: :edition, traits: [:draft]
  factory :submitted_edition, parent: :edition, traits: [:submitted]
  factory :rejected_edition, parent: :edition, traits: [:rejected]
  factory :published_edition, parent: :edition, traits: [:published]
  factory :deleted_edition, parent: :edition, traits: [:deleted]
  factory :superseded_edition, parent: :edition, traits: [:superseded]
  factory :scheduled_edition, parent: :edition, traits: [:scheduled]
  factory :unpublished_edition, parent: :edition, traits: %i[draft unpublished]
  factory :withdrawn_edition, parent: :edition, traits: [:withdrawn]
  factory :protected_edition, parent: :edition, traits: [:access_limited]
  factory :edition_with_organisations, parent: :edition, traits: [:with_organisations]
end
