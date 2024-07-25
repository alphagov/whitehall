module ContentObjectStore
  class CreateEditionService
    include Publishable

    def initialize(schema)
      @schema = schema
    end

    def call(edition_params)
      title = edition_params[:document_attributes][:title]
      details = edition_params[:details]

      publish_with_rollback(schema: @schema, title:, details:) do
        @new_edition = ContentObjectStore::ContentBlock::Edition.create!(edition_params)
      end

      @new_edition
    end
  end
end
