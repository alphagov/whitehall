FactoryBot.define do
  factory :content_block_edition, class: "ContentObjectStore::ContentBlockEdition" do
    details { "{}" }
    created_at { Time.zone.now.utc }
    updated_at { Time.zone.now.utc }

    ContentObjectStore::ContentBlockSchema.valid_schemas.each do |type|
      trait type.to_sym do
        block_type { type }
        content_block_document { build(:content_block_document, type.to_sym) }
      end
    end
  end
end
