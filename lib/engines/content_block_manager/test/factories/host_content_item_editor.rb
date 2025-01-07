FactoryBot.define do
  factory :host_content_item_editor, class: "ContentBlockManager::HostContentItem::Editor" do
    uid { SecureRandom.uuid }
    sequence(:name) { |i| "Someone #{i}" }
    sequence(:email) { |i| "someone-#{i}@example.com" }
    organisation { build(:host_content_item_editor_organisation) }

    initialize_with do
      new(
        uid:,
        name:,
        email:,
        organisation:,
      )
    end
  end
end
