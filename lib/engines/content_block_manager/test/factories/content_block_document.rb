FactoryBot.define do
  factory :content_block_document, class: "ContentBlockManager::ContentBlock::Document" do
    sequence(:content_id) { SecureRandom.uuid }
    sluggable_string { "factory-example-title" }
    created_at { Time.zone.now.utc }
    updated_at { Time.zone.now.utc }
    latest_edition_id { nil }
    live_edition_id { nil }

    ContentBlockManager::ContentBlock::Schema.valid_schemas.each do |type|
      trait type.to_sym do
        block_type { type }
      end
    end
  end
end
