FactoryBot.define do
  factory :content_block_document, class: "ContentBlockManager::ContentBlock::Document" do
    sequence(:content_id) { SecureRandom.uuid }
    sluggable_string { "factory-example-title" }
    created_at { Time.zone.now.utc }
    updated_at { Time.zone.now.utc }
    latest_edition_id { nil }
    live_edition_id { nil }
    block_type { "pension" }

    transient do
      schema { nil }
    end

    ContentBlockManager::ContentBlock::Schema.valid_schemas.each do |type|
      trait type.to_sym do
        block_type { type }
        schema { build(:content_block_schema, block_type: type) }
      end
    end

    after(:build) do |content_block_document, evaluator|
      content_block_document.stubs(:schema).returns(evaluator.schema)
    end
  end
end
