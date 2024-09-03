module ContentObjectStore
  class ScheduleEditionService
    include Publishable

    def initialize(original_content_block_edition)
      @original_content_block_edition = original_content_block_edition
    end

    def call(edition_params)
      raise ArgumentError, "Edition params must be provided" if edition_params.blank? || edition_params[:details].blank?

      update_document_params = edition_params[:document_attributes] || {}

      schedule_with_rollback do
        @new_content_block_edition = create_new_content_block_edition_for_document(edition_params:)

        update_content_block_document(
          new_content_block_edition: @new_content_block_edition,
          update_document_params:,
        )

        @new_content_block_edition
      end

      @new_content_block_edition
    end
  end
end
