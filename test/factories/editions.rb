GenericEdition = Class.new(Edition)

Rails.application.routes.url_helpers.module_eval do
  def generic_edition_path(id)
    "/government/generic-documents/#{id}"
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

    trait(:draft) { state "draft" }
    trait(:submitted) { state "submitted" }
    trait(:rejected) { state "rejected" }
    trait(:published) do
      state "published"
      published_at { 1.day.ago }
      first_published_at { published_at }
      force_published { false }
    end
    trait(:deleted) { state "deleted" }
    trait(:archived) { state "archived" }
    trait(:featured) { featured true }
  end

  factory :draft_edition, parent: :edition, traits: [:draft]
  factory :submitted_edition, parent: :edition, traits: [:submitted]
  factory :rejected_edition, parent: :edition, traits: [:rejected]
  factory :published_edition, parent: :edition, traits: [:published]
  factory :deleted_edition, parent: :edition, traits: [:deleted]
  factory :archived_edition, parent: :edition, traits: [:archived]
end