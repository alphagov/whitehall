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

  private

    def create_new_content_block_edition_for_document(edition_params:)
      @original_content_block_edition.assign_attributes(
        filter_params_for_validation_check(edition_params),
      )

      unless @original_content_block_edition.valid?
        raise ActiveRecord::RecordInvalid, @original_content_block_edition
      end

      new_content_block_edition = ContentObjectStore::ContentBlock::Edition.new(edition_params)
      new_content_block_edition.document_id = @original_content_block_edition.document.id
      new_content_block_edition.save!
      new_content_block_edition
    end

    def update_content_block_document(new_content_block_edition:, update_document_params:)
      update_document_params[:latest_edition_id] = new_content_block_edition.id
      update_document_params[:live_edition_id] = new_content_block_edition.id

      # Updates to a Document should never change its block type
      update_document_params.delete(:block_type)

      new_content_block_edition.document.update!(update_document_params)
    end

    def filter_params_for_validation_check(edition_params)
      # Remove the `creator` as this is not modifiable and will return a false negative
      validation_params = edition_params.except(:creator)

      # Remove document `block_type`` as this is not modifiable
      # Add the original Document ID to avoid `valid?` creating a new Document
      if validation_params.key?(:document_attributes)
        validation_params[:document_attributes] = validation_params[:document_attributes]
                                                    .except(:block_type)
                                                    .merge(id: @original_content_block_edition.document.id)
      end

      validation_params
    end
  end
end
