FactoryBot.define do
  factory :host_content_item_editor_organisation, class: "ContentBlockManager::HostContentItem::Editor::Organisation" do
    content_id { SecureRandom.uuid }
    sequence(:name) { |i| "organisation #{i}" }
    sequence(:slug) { |i| "organisation-#{i}" }

    initialize_with do
      new(
        content_id:,
        name:,
        slug:,
      )
    end
  end
end
