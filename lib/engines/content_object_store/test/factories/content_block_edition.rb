FactoryBot.define do
  factory :content_block_edition, class: "ContentObjectStore::ContentBlockEdition" do
    details { {} }
    created_at { Time.zone.now.utc }
    updated_at { Time.zone.now.utc }
    schema { build(:content_block_schema) }
    creator

    content_block_document_attributes { FactoryBot.attributes_for(:content_block_document, :email_address) }

    ContentObjectStore::ContentBlockSchema.valid_schemas.each do |type|
      trait type.to_sym do
        content_block_document_attributes do
          FactoryBot.attributes_for(:content_block_document, :email_address, block_type: type)
        end
      end
    end

    after(:build) do |content_block_edition, evaluator|
      document = build(:content_block_document, evaluator.content_block_document_attributes)
      content_block_edition.content_block_document = document
    end

    after(:create) do |content_block_edition, evaluator|
      unless content_block_edition.content_block_document_id
        document = create(:content_block_document, evaluator.content_block_document_attributes)
        content_block_edition.update!(content_block_document_id: document.id)
      end
    end
  end
end
