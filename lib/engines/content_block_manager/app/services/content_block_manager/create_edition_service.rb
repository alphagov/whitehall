module ContentBlockManager
  class CreateEditionService
    def initialize(schema)
      @schema = schema
    end

    def call(edition_params, document_id: nil)
      @new_edition = build_edition(edition_params, document_id)
      @new_edition.assign_attributes(edition_params)
      @new_edition.save!
      @new_edition
    end

  private

    def build_edition(edition_params, document_id)
      if document_id.nil?
        ContentBlockManager::ContentBlock::Edition.new(edition_params)
      else
        ContentBlockManager::ContentBlock::Edition.new(
          document_id:,
          title: edition_params[:title],
          document_attributes: edition_params.delete(:document_attributes)
                                             .except(:block_type)
                                             .merge({ id: document_id }),
        )
      end
    end
  end
end
