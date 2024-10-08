module ContentObjectStore
  class CreateEditionService
    include Publishable

    def initialize(schema)
      @schema = schema
    end

    def call(edition_params, document_id: nil)
      @new_edition = build_edition(edition_params, document_id)
      @new_edition.assign_attributes(edition_params)
      @new_edition.save!
      @new_edition.update_document_reference_to_latest_edition!
      @new_edition
    end

  private

    def build_edition(edition_params, document_id)
      if document_id.nil?
        ContentObjectStore::ContentBlock::Edition.new(edition_params)
      else
        ContentObjectStore::ContentBlock::Edition.new(
          document_id:,
          document_attributes: edition_params.delete(:document_attributes).except(:block_type).merge({ id: document_id }),
        )
      end
    end
  end
end
