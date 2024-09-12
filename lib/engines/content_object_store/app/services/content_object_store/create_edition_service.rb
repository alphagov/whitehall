module ContentObjectStore
  class CreateEditionService
    include Publishable

    def initialize(schema)
      @schema = schema
    end

    def call(edition_params)
      @new_edition = ContentObjectStore::ContentBlock::Edition.create!(edition_params)
      @new_edition.update_document_reference_to_latest_edition!
      # TODO: error scenario?
      @new_edition
    end
  end
end
