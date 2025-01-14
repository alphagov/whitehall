FactoryBot.define do
  factory :host_content_item, class: "ContentBlockManager::HostContentItem" do
    title { "title" }
    base_path { "/foo/bar" }
    document_type { "something" }
    publishing_organisation { { name: "organisation", content_id: SecureRandom.uuid } }
    publishing_app { "publishing_app" }
    last_edited_by_editor { build(:signon_user) }
    last_edited_at { 2.days.ago.to_s }
    unique_pageviews { 123 }
    instances { 1 }
    host_content_id { SecureRandom.uuid }

    initialize_with do
      new(title:,
          base_path:,
          document_type:,
          publishing_organisation:,
          publishing_app:,
          last_edited_by_editor:,
          last_edited_at:,
          unique_pageviews:,
          host_content_id:,
          instances:)
    end
  end
end
