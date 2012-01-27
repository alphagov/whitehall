GenericDocument = Class.new(Document)

Rails.application.routes.url_helpers.module_eval do
  def generic_document_path(id)
    "/government/generic-documents/#{id}"
  end

  def admin_generic_document_editorial_remarks_path(*args)
    admin_document_editorial_remarks_path(*args)
  end
end

FactoryGirl.define do
  factory :document, class: GenericDocument do
    creator
    title "document-title"
    body "document-body"

    trait(:draft) { state "draft" }
    trait(:submitted) { state "submitted" }
    trait(:rejected) { state "rejected" }
    trait(:published) do
      state "published"
      published_at { 1.day.ago }
      first_published_at { published_at }
    end
    trait(:deleted) { state "deleted" }
    trait(:archived) { state "archived" }
    trait(:featured) { featured true }
  end

  factory :draft_document, parent: :document, traits: [:draft]
  factory :submitted_document, parent: :document, traits: [:submitted]
  factory :rejected_document, parent: :document, traits: [:rejected]
  factory :published_document, parent: :document, traits: [:published]
  factory :deleted_document, parent: :document, traits: [:deleted]
  factory :archived_document, parent: :document, traits: [:archived]
end