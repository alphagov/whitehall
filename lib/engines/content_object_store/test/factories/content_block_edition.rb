FactoryBot.define do
  factory :content_block_edition, class: "ContentObjectStore::ContentBlockEdition" do
    details { "{}" }
    created_at { Time.zone.now.utc }
    updated_at { Time.zone.now.utc }
  end
end
