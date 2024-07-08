FactoryBot.define do
  factory :content_block_schema, class: "ContentObjectStore::ContentBlockSchema" do
    block_type { "email_address" }
    body { {} }

    initialize_with do
      new("#{ContentObjectStore::ContentBlockSchema::SCHEMA_PREFIX}_#{block_type}", body)
    end
  end
end
