module ContentObjectStore
  class CreateEditionService
    include Publishable

    def initialize(schema, edition_params)
      @schema = schema
      @edition_params = edition_params
    end

    def call
      ActiveRecord::Base.transaction do
        content_block_edition = create_whitehall_edition
        content_id = content_block_edition.document.content_id
        create_publishing_api_edition(
          content_id:,
          schema_id: @schema.id,
          document_title: @edition_params[:document_title],
          details: @edition_params[:details].to_h,
        )
        publish_publishing_api_edition(content_id:)
      rescue PublishingFailureError => e
        discard_publishing_api_edition(content_id:)
        raise e
      end
    end

  private

    def create_whitehall_edition
      ContentObjectStore::ContentBlockEdition.create!(@edition_params)
    end
  end
end
