FactoryBot.define do
  factory :content_block_schema, class: "ContentObjectStore::ContentBlock::Schema" do
    body { {} }
    block_type { "block_type" }

    ContentObjectStore::ContentBlock::Schema.valid_schemas.each do |type|
      trait type.to_sym do
        block_type { type }
      end
    end

    initialize_with do
      new("#{ContentObjectStore::ContentBlock::Schema::SCHEMA_PREFIX}_#{block_type}", body)
    end
  end
end
