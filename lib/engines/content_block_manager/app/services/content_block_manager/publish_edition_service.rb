module ContentBlockManager
  class PublishEditionService
    class PublishingFailureError < StandardError; end

    include Concerns::Dequeueable

    def call(edition)
      publish_with_rollback(edition)
    end

  private

    def publish_with_rollback(content_block_edition)
      document = content_block_edition.document
      schema = ContentBlockManager::ContentBlock::Schema.find_by_block_type(document.block_type)
      content_id = document.content_id
      content_id_alias = document.content_id_alias

      create_publishing_api_edition(
        content_id:,
        content_id_alias:,
        schema_id: schema.id,
        title: content_block_edition.document_title,
        details: content_block_edition.details,
        instructions_to_publishers: content_block_edition.instructions_to_publishers,
        links: {
          primary_publishing_organisation: [
            content_block_edition.lead_organisation.content_id,
          ],
        },
      )
      dequeue_current_edition_if_previously_scheduled(content_block_edition)
      dequeue_all_previously_queued_editions(content_block_edition)
      publish_publishing_api_edition(content_id:)
      update_content_block_document_with_latest_edition(content_block_edition)
      content_block_edition.public_send(:publish!)
      content_block_edition
    rescue PublishingFailureError => e
      discard_publishing_api_edition(content_id:)
      raise e
    end

    def create_publishing_api_edition(content_id:, content_id_alias:, schema_id:, title:, instructions_to_publishers:, details:, links:)
      Services.publishing_api.put_content(content_id, {
        schema_name: schema_id,
        document_type: schema_id,
        publishing_app: Whitehall::PublishingApp::WHITEHALL,
        title:,
        instructions_to_publishers:,
        content_id_alias:,
        details:,
        links:,
        update_type: "major",
      })
    end

    def publish_publishing_api_edition(content_id:)
      Services.publishing_api.publish(content_id, "content_block")
    rescue GdsApi::HTTPErrorResponse => e
      raise PublishingFailureError, "Could not publish #{content_id} because: #{e.message}"
    end

    def update_content_block_document_with_latest_edition(content_block_edition)
      content_block_edition.document.update!(
        latest_edition_id: content_block_edition.id,
        live_edition_id: content_block_edition.id,
      )
    end

    def discard_publishing_api_edition(content_id:)
      Services.publishing_api.discard_draft(content_id)
    end
  end
end
