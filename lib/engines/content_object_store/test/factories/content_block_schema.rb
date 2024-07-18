FactoryBot.define do
  factory :content_block_schema, class: "ContentObjectStore::ContentBlockSchema" do
    body { {} }
    block_type { "block_type" }

    ContentObjectStore::ContentBlockSchema.valid_schemas.each do |type|
      trait type.to_sym do
        block_type { type }
      end
    end

    initialize_with do
      new("#{ContentObjectStore::ContentBlockSchema::SCHEMA_PREFIX}_#{block_type}", body)
    end
  end
end
