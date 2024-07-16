module ContentObjectStore
  module Publishable
    class PublishingFailureError < StandardError; end

    def publish_with_rollback(schema:, title:, details:)
      raise ArgumentError, "Local database changes not given" unless block_given?

      ActiveRecord::Base.transaction do
        content_block_edition = yield
        content_id = content_block_edition.document.content_id

        create_publishing_api_edition(
          content_id:,
          schema_id: schema.id,
          title:,
          details: details.to_h,
        )
        publish_publishing_api_edition(content_id:)
      rescue PublishingFailureError => e
        discard_publishing_api_edition(content_id:)
        raise e
      end
    end

  private

    def create_publishing_api_edition(content_id:, schema_id:, title:, details:)
      Services.publishing_api.put_content(content_id, {
        schema_name: schema_id,
        document_type: schema_id,
        publishing_app: Whitehall::PublishingApp::WHITEHALL,
        title:,
        details:,
      })
    end

    def publish_publishing_api_edition(content_id:)
      Services.publishing_api.publish(content_id, "major")
    rescue GdsApi::HTTPErrorResponse => e
      raise PublishingFailureError, "Could not publish #{content_id} because: #{e.message}"
    end

    def discard_publishing_api_edition(content_id:)
      Services.publishing_api.discard_draft(content_id)
    end
  end
end
