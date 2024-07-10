FactoryBot.define do
  factory :content_block_edition, class: "ContentObjectStore::ContentBlockEdition" do
    details { "{}" }
    created_at { Time.zone.now.utc }
    updated_at { Time.zone.now.utc }

    ContentObjectStore::ContentBlockSchema.valid_schemas.each do |type|
      trait type.to_sym do
        block_type { type }
      end
    end
  end
end
