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
    end

    def create_content_block_edition
      @original_content_block_edition.create_copy(edition_params: @edition_params)
    end
  end
end
