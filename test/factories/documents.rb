FactoryGirl.define do
  factory :document do
    author
    title "document-title"
    body "document-body"

    trait(:draft) { state "draft" }
    trait(:submitted) { state "submitted" }
    trait(:rejected) { state "rejected" }
    trait(:published) { state "published" }
    trait(:deleted) { state "deleted" }
    trait(:archived) { state "archived" }
  end

  factory :draft_document, parent: :document, traits: [:draft]
  factory :submitted_document, parent: :document, traits: [:submitted]
  factory :rejected_document, parent: :document, traits: [:rejected]
  factory :published_document, parent: :document, traits: [:published]
  factory :deleted_document, parent: :document, traits: [:deleted]
  factory :archived_document, parent: :document, traits: [:archived]
end