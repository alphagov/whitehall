FactoryBot.define do
  factory :content_block_edition, class: "ContentBlockManager::ContentBlock::Edition" do
    details { {} }
    created_at { Time.zone.now.utc }
    updated_at { Time.zone.now.utc }
    schema { build(:content_block_schema) }
    creator

    organisation { FactoryBot.build(:organisation) }

    document_id { nil }

    scheduled_publication { nil }

    ContentBlockManager::ContentBlock::Schema.valid_schemas.each do |type|
      trait type.to_sym do
        document { build(:content_block_document, block_type: type) }
      end
    end

    after :build do |edition, evaluator|
      if evaluator.organisation
        edition.build_edition_organisation(
          organisation: evaluator.organisation,
        )
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
