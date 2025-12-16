FactoryBot.define do
  factory :standard_edition, class: StandardEdition, parent: :edition do
    sequence(:title) { |index| "standard-edition-title-#{index}" }
    summary { "standard-edition-summary" }
    previously_published { false }
    configurable_document_type { "test_type" }
    block_content { {} }
    body { nil }

    factory :draft_standard_edition, parent: :standard_edition, traits: [:draft]
    factory :submitted_standard_edition, parent: :standard_edition, traits: [:submitted]
    factory :rejected_standard_edition, parent: :standard_edition, traits: [:rejected]
    factory :force_published_standard_edition, parent: :standard_edition, traits: [:force_published]
    factory :published_standard_edition, parent: :standard_edition, traits: [:published]
    factory :deleted_standard_edition, parent: :standard_edition, traits: [:deleted]
    factory :superseded_standard_edition, parent: :standard_edition, traits: [:superseded]
    factory :scheduled_standard_edition, parent: :standard_edition, traits: [:scheduled]
    factory :unpublished_standard_edition, parent: :standard_edition, traits: [:unpublished]
    factory :unpublished_standard_edition_in_error_no_redirect,
            parent: :standard_edition,
            traits: %i[published_in_error_no_redirect]
    factory :unpublished_standard_edition_in_error_redirect,
            parent: :standard_edition,
            traits: %i[published_in_error_redirect]
    factory :unpublished_standard_edition_consolidated,
            parent: :standard_edition,
            traits: %i[consolidated_redirect]
    factory :withdrawn_standard_edition, parent: :standard_edition, traits: [:withdrawn]
  end
end
