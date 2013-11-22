FactoryGirl.define do
  factory :document_collection, class: DocumentCollection, parent: :edition, traits: [:with_organisations, :with_topics] do
    trait(:with_group) do
      groups { FactoryGirl.build_list :document_collection_group, 1 }
    end
  end

  factory :imported_document_collection, parent: :document_collection, traits: [:imported]
  factory :draft_document_collection, parent: :document_collection, traits: [:draft]
  factory :submitted_document_collection, parent: :document_collection, traits: [:submitted]
  factory :rejected_document_collection, parent: :document_collection, traits: [:rejected]
  factory :published_document_collection, parent: :document_collection, traits: [:published]
  factory :deleted_document_collection, parent: :document_collection, traits: [:deleted]
  factory :superseded_document_collection, parent: :document_collection, traits: [:superseded]
  factory :scheduled_document_collection, parent: :document_collection, traits: [:scheduled]
  factory :unpublished_document_collection, parent: :document_collection, traits: [:draft, :unpublished]
end
