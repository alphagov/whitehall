module ContentObjectStore
  class UpdateEditionService
    include Publishable

    def initialize(schema, original_content_block_edition, change_dispatcher = ContentObjectStore::ChangeDispatcher::Now.new)
      @schema = schema
      @original_content_block_edition = original_content_block_edition
      @change_dispatcher = change_dispatcher
    end

    def call(edition_params)
      raise ArgumentError, "Edition params must be provided" if edition_params.blank? || edition_params[:details].blank?

      @edition_params = edition_params
      @title = edition_params.dig(:document_attributes, :title) || @original_content_block_edition.document.title
      @details = edition_params[:details]
      @update_document_params = edition_params[:document_attributes] || {}

      remove_any_old_scheduled_jobs

      case @change_dispatcher
      when ContentObjectStore::ChangeDispatcher::Now
        publish_now
      when ContentObjectStore::ChangeDispatcher::Schedule
        schedule
      else
        raise ArgumentError, "#{@change_dispatcher.class} is not a known change dispatcher"
      end

      ContentObjectStore::ResultMonad.new(
        @new_content_block_edition.persisted?,
        "#{@schema.name} #{@change_dispatcher.verb} successfully",
        @new_content_block_edition,
      )
    rescue ActiveRecord::RecordInvalid => e
      ContentObjectStore::ResultMonad.new(
        false,
        e.message,
        e.record,
      )
    end

  private

    def remove_any_old_scheduled_jobs
      ContentObjectStore::SchedulePublishingWorker.dequeue(@original_content_block_edition)
    end

    def publish_now
      publish_with_rollback(schema: @schema, title: @title, details: @details) do
        @new_content_block_edition = create_content_block_edition
        update_content_block_document(
          new_content_block_edition: @new_content_block_edition,
          update_document_params: @update_document_params,
        )
      end
    end

    def schedule
      schedule_with_rollback do
        @new_content_block_edition = create_content_block_edition
        update_content_block_document(
          new_content_block_edition: @new_content_block_edition,
          update_document_params: @update_document_params,
        )
      end
      send_publish_intents_for_host_documents(content_block_edition: @new_content_block_edition)
    end

    def create_content_block_edition
      @original_content_block_edition.create_copy(edition_params: @edition_params)
    end

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
