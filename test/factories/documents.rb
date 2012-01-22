FactoryGirl.define do
  factory :document do
    creator
    title "document-title"
    body "document-body"

    trait(:draft) { state "draft" }
    trait(:submitted) { state "submitted" }
    trait(:rejected) { state "rejected" }
    trait(:published) do
      state "published"
      published_at { 1.day.ago }
    end
    trait(:deleted) { state "deleted" }
    trait(:archived) { state "archived" }
    trait(:featured) { featuring }
  end

  factory :draft_document, parent: :document, traits: [:draft]
  factory :submitted_document, parent: :document, traits: [:submitted]
  factory :rejected_document, parent: :document, traits: [:rejected]
  factory :published_document, parent: :document, traits: [:published]
  factory :deleted_document, parent: :document, traits: [:deleted]
  factory :archived_document, parent: :document, traits: [:archived]
end