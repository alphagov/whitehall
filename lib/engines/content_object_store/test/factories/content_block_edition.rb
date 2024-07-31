FactoryBot.define do
  factory :content_block_edition, class: "ContentObjectStore::ContentBlock::Edition" do
    details { {} }
    created_at { Time.zone.now.utc }
    updated_at { Time.zone.now.utc }
    schema { build(:content_block_schema) }
    creator

    document_id { nil }

    ContentObjectStore::ContentBlock::Schema.valid_schemas.each do |type|
      trait type.to_sym do
        document { build(:content_block_document, block_type: type) }
      end
    end

    after(:create) do |content_block_edition, _evaluator|
      document_update_params = {
        latest_edition_id: content_block_edition.id,
      }
      content_block_edition.document.update!(document_update_params)
    end
  end
end
