module ContentBlockManager
  module Publishable
    class PublishingFailureError < StandardError; end

    def publish_with_rollback(content_block_edition)
      document = content_block_edition.document
      schema = ContentBlockManager::ContentBlock::Schema.find_by_block_type(document.block_type)
      content_id = document.content_id
      content_id_alias = document.content_id_alias

      create_publishing_api_edition(
        content_id:,
        content_id_alias:,
        schema_id: schema.id,
        title: content_block_edition.title,
        details: content_block_edition.details,
        links: {
          primary_publishing_organisation: [
            content_block_edition.lead_organisation.content_id,
          ],
        },
      )
      publish_publishing_api_edition(content_id:)
      update_content_block_document_with_latest_edition(content_block_edition)
      content_block_edition.public_send(:publish!)
      content_block_edition
    rescue PublishingFailureError => e
      discard_publishing_api_edition(content_id:)
      raise e
    end

    def schedule_with_rollback
      raise ArgumentError, "Local database changes not given" unless block_given?

      ActiveRecord::Base.transaction do
        content_block_edition = yield

        content_block_edition.schedule!
        ContentBlockManager::SchedulePublishingWorker.queue(content_block_edition)
      end
    end

    def create_draft_edition(schema)
      raise ArgumentError, "Local database changes not given" unless block_given?

      ActiveRecord::Base.transaction do
        content_block_edition = yield
        content_id = content_block_edition.document.content_id
        content_id_alias = content_block_edition.document.content_id_alias
        organisation_id = content_block_edition.lead_organisation.content_id

        create_publishing_api_edition(
          content_id:,
          content_id_alias:,
          schema_id: schema.id,
          title: content_block_edition.title,
          details: content_block_edition.details.to_h,
          links: {
            primary_publishing_organisation: [
              organisation_id,
            ],
          },
        )
      end
    end

    def update_content_block_document(new_content_block_edition:, update_document_params:)
      # Updates to a Document should never change its block type
      update_document_params.delete(:block_type)

      new_content_block_edition.document.update!(update_document_params)
      new_content_block_edition
    end

  private

    def create_publishing_api_edition(content_id:, content_id_alias:, schema_id:, title:, details:, links:)
      Services.publishing_api.put_content(content_id, {
        schema_name: schema_id,
        document_type: schema_id,
        publishing_app: Whitehall::PublishingApp::WHITEHALL,
        title:,
        content_id_alias:,
        details:,
        links:,
      })
    end

    def publish_publishing_api_edition(content_id:)
      Services.publishing_api.publish(content_id, "content_block")
    rescue GdsApi::HTTPErrorResponse => e
      raise PublishingFailureError, "Could not publish #{content_id} because: #{e.message}"
    end

    def discard_publishing_api_edition(content_id:)
      Services.publishing_api.discard_draft(content_id)
    end

    def update_content_block_document_with_latest_edition(content_block_edition)
      content_block_edition.document.update!(
        latest_edition_id: content_block_edition.id,
        live_edition_id: content_block_edition.id,
      )
    end
  end
end
