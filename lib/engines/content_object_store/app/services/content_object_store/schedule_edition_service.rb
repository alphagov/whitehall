module ContentObjectStore
  class ScheduleEditionService
    include Publishable

    def initialize(schema)
      @schema = schema
    end

    def call(edition, scheduled_publication_params)
      schedule_with_rollback do
        edition.update!(scheduled_publication_params)
        edition.update_document_reference_to_latest_edition!
        edition
      end
      send_publish_intents_for_host_documents(content_block_edition: edition)
      edition
    end

  private

    def send_publish_intents_for_host_documents(content_block_edition:)
      host_content_items = ContentObjectStore::GetHostContentItems.by_embedded_document(
        content_block_document: content_block_edition.document,
      )
      host_content_items.each do |host_content_item|
        ContentObjectStore::PublishIntentWorker.perform_async(
          host_content_item.base_path,
          host_content_item.publishing_app,
          content_block_edition.scheduled_publication.to_s,
        )
      end
    end
  end
end
