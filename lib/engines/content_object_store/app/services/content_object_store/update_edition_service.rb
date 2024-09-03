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

      case @change_dispatcher
      when ContentObjectStore::ChangeDispatcher::Now
        new_content_block_edition = publish_now
      when ContentObjectStore::ChangeDispatcher::Schedule
        new_content_block_edition = schedule
      else
        raise ArgumentError, "#{@change_dispatcher.class} is not a known change dispatcher"
      end

      ContentObjectStore::ResultMonad.new(
        new_content_block_edition.persisted?,
        "#{@schema.name} #{@change_dispatcher.verb} successfully",
        new_content_block_edition,
      )
    end

  private

    def publish_now
      publish_with_rollback(schema: @schema, title: @title, details: @details) do
        @new_content_block_edition = create_new_content_block_edition_for_document(edition_params: @edition_params)

        update_content_block_document(
          new_content_block_edition: @new_content_block_edition,
          update_document_params: @update_document_params,
        )

        @new_content_block_edition
      end
      @new_content_block_edition
    end

    def schedule
      schedule_with_rollback do
        @new_content_block_edition = create_new_content_block_edition_for_document(edition_params: @edition_params)

        update_content_block_document(
          new_content_block_edition: @new_content_block_edition,
          update_document_params: @update_document_params,
        )

        @new_content_block_edition
      end
      @new_content_block_edition
    end
  end
end
