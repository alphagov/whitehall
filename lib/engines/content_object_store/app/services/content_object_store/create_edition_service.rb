module ContentObjectStore
  class CreateEditionService
    include Publishable

    def initialize(schema)
      @schema = schema
    end

    def call(edition_params)
      title = edition_params[:content_block_document_attributes][:title]
      details = edition_params[:details]

      publish_with_rollback(schema: @schema, title:, details:) do
        @new_edition = ContentObjectStore::ContentBlockEdition.create!(edition_params)
      end

      @new_edition
    end
  end
end
