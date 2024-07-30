module ContentObjectStore
  class CreateEditionService
    include Publishable

    def initialize(schema)
      @schema = schema
    end

    def call(edition_params)
      @new_edition = ContentObjectStore::ContentBlock::Edition.create!(edition_params)
      update_content_block_document_with_latest_edition(@new_edition)
      # TODO: error scenario?
      @new_edition
    end
  end
end
