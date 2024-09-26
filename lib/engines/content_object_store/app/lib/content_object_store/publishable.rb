module ContentObjectStore
  module Publishable
    class PublishingFailureError < StandardError; end

    def publish_with_rollback(schema:, title:, details:)
      raise ArgumentError, "Local database changes not given" unless block_given?

      ActiveRecord::Base.transaction do
        content_block_edition = yield
        content_id = content_block_edition.document.content_id
        organisation_id = content_block_edition.lead_organisation.content_id

        create_publishing_api_edition(
          content_id:,
          schema_id: schema.id,
          title:,
          details: details.to_h,
          links: {
            primary_publishing_organisation: [
              organisation_id,
            ],
          },
        )
        publish_publishing_api_edition(content_id:)
        update_content_block_document_with_live_edition(content_block_edition)
        content_block_edition.public_send(:publish!)
        host_content_items = ContentObjectStore::GetHostContentItems.by_embedded_document(
          content_block_document: content_block_edition.document,
        )

        remove_cache_for_host_content(content_block_edition:, host_content_items:)
        add_editorial_remarks_to_host_content(content_block_edition:, host_content_items:, content_id:)
      rescue PublishingFailureError => e
        discard_publishing_api_edition(content_id:)
        raise e
      end
    end

    def schedule_with_rollback
      raise ArgumentError, "Local database changes not given" unless block_given?

      ActiveRecord::Base.transaction do
        content_block_edition = yield

        content_block_edition.schedule!
        ContentObjectStore::SchedulePublishingWorker.queue(content_block_edition)
      end
    end

    def update_content_block_document(new_content_block_edition:, update_document_params:)
      # Updates to a Document should never change its block type
      update_document_params.delete(:block_type)

      new_content_block_edition.document.update!(update_document_params)
      new_content_block_edition
    end

  private

    def add_editorial_remarks_to_host_content(content_block_edition:, host_content_items:, content_id:)
      host_content_items.each do |host_content_item|
        puts "here in add remark"
        # TODO: only if Whitehall publishing_app
        # TODO: push this to an asyncrhonous job as could be 100s of items
        host_edition = Document.find_by(content_id: host_content_item.content_id).live_edition
        EditorialRemark.create!(
          edition: host_edition,
          body: "Content Block of title #{content_block_edition.title} and ID #{content_id} was updated",
          author: Current.user,
          created_at: Time.zone.now,
          updated_at: Time.zone.now,
        )
      end
    end

    def remove_cache_for_host_content(content_block_edition:, host_content_items:)
      host_content_items.each do |host_content_item|
        ContentObjectStore::PublishIntentWorker.perform_async(
          host_content_item.base_path,
          host_content_item.publishing_app,
          Time.zone.now.to_s,
        )
      end
    end

    def create_publishing_api_edition(content_id:, schema_id:, title:, details:, links:)
      Services.publishing_api.put_content(content_id, {
        schema_name: schema_id,
        document_type: schema_id,
        publishing_app: Whitehall::PublishingApp::WHITEHALL,
        title:,
        details:,
        links:,
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

    def update_content_block_document_with_live_edition(content_block_edition)
      content_block_edition.document.update!(live_edition_id: content_block_edition.id)
    end
  end
end
