FactoryBot.define do
  factory :host_content_item, class: "ContentObjectStore::HostContentItem" do
    title { "title" }
    base_path { "/foo/bar" }
    document_type { "something" }
    publishing_organisation { { name: "organisation", content_id: SecureRandom.uuid } }
    publishing_app { "publishing_app" }

    initialize_with { new(title:, base_path:, document_type:, publishing_organisation:, publishing_app:) }
  end
end
