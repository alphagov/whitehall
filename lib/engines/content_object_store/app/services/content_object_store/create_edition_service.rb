module ContentObjectStore
  class CreateEditionService
    def initialize(schema, edition_params)
      @schema = schema
      @edition_params = edition_params
    end

    def call
      ActiveRecord::Base.transaction do
        content_block_edition = create_whitehall_edition
        create_publishing_api_edition(content_id: content_block_edition.document.content_id)
      end
    end

  private

    def create_whitehall_edition
      ContentObjectStore::ContentBlockEdition.create!(@edition_params)
    end

    def create_publishing_api_edition(content_id:)
      Services.publishing_api.put_content(content_id, {
        schema_name: @schema.id,
        document_type: @schema.id,
        publishing_app: Whitehall::PublishingApp::WHITEHALL,
        title: @edition_params[:document_title],
        details: @edition_params[:details].to_h,
      })
    end
  end
end
