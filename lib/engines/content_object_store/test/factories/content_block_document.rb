FactoryBot.define do
  factory :content_block_document, class: "ContentObjectStore::ContentBlockDocument" do
    sequence(:content_id) { SecureRandom.uuid }
    title { "Title" }
    created_at { Time.zone.now.utc }
    updated_at { Time.zone.now.utc }

    ContentObjectStore::ContentBlockSchema::VALID_SCHEMAS.each do |type|
      trait type.to_sym do
        block_type { type }
      end
    end
  end
end
