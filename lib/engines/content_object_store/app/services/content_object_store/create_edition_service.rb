module ContentObjectStore
  class CreateEditionService
    class PublishingFailureError < StandardError; end

    def initialize(schema, edition_params)
      @schema = schema
      @edition_params = edition_params
    end

    def call
      ActiveRecord::Base.transaction do
        content_block_edition = create_whitehall_edition
        content_id = content_block_edition.document.content_id
        create_publishing_api_edition(content_id:)
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

    def create_publishing_api_edition(content_id:)
      Services.publishing_api.put_content(content_id, {
        schema_name: @schema.id,
        document_type: @schema.id,
        publishing_app: Whitehall::PublishingApp::WHITEHALL,
        title: @edition_params[:document_title],
        details: @edition_params[:details].to_h,
      })
    end

    def publish_publishing_api_edition(content_id:)
      Services.publishing_api.publish(content_id)
    rescue GdsApi::HTTPErrorResponse => e
      raise PublishingFailureError, "Could not publish #{content_id} because: #{e.message}"
    end

    def discard_publishing_api_edition(content_id:)
      Services.publishing_api.discard_draft(content_id)
    end
  end
end
