require_relative "../support/searchable_edition"

FactoryBot.define do
  factory :searchable_edition, class: SearchableEdition, parent: :edition

  factory :published_searchable_edition, parent: :searchable_edition, traits: [:published]
  factory :withdrawn_searchable_edition, parent: :searchable_edition, traits: [:withdrawn]
  factory :submitted_searchable_edition, parent: :searchable_edition, traits: [:submitted]
end
