module ContentBlockManager
  class ScheduleEditionService
    include Concerns::Dequeueable

    def initialize(schema)
      @schema = schema
    end

    def call(edition)
      schedule_with_rollback do
        edition.update_document_reference_to_latest_edition!
        edition
      end
      send_publish_intents_for_host_documents(content_block_edition: edition)
      edition
    end

  private

    def schedule_with_rollback
      raise ArgumentError, "Local database changes not given" unless block_given?

      ActiveRecord::Base.transaction do
        content_block_edition = yield

        content_block_edition.schedule! unless content_block_edition.scheduled?

        dequeue_all_previously_queued_editions(content_block_edition)
        ContentBlockManager::SchedulePublishingWorker.queue(content_block_edition)
      end
    end

    def send_publish_intents_for_host_documents(content_block_edition:)
      host_content_items = ContentBlockManager::HostContentItem.for_document(content_block_edition.document)
      host_content_items.each do |host_content_item|
        ContentBlockManager::PublishIntentWorker.perform_async(
          host_content_item.base_path,
          host_content_item.publishing_app,
          content_block_edition.scheduled_publication.to_s,
        )
      end
    end
  end
end
