module ContentObjectStore
  class UpdateEditionService
    include Publishable

    def initialize(schema, original_content_block_edition)
      @schema = schema
      @original_content_block_edition = original_content_block_edition
    end

    def call(edition_params)
      raise ArgumentError, "Edition params must be provided" if edition_params.blank? || edition_params[:details].blank?

      title = edition_params.dig(:content_block_document_attributes, :title) || @original_content_block_edition.document.title
      details = edition_params[:details]
      update_document_params = edition_params[:content_block_document_attributes] || {}

      publish_with_rollback(schema: @schema, title:, details:) do
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
      new_content_block_edition = ContentObjectStore::ContentBlockEdition.new(edition_params)
      new_content_block_edition.document = @original_content_block_edition.document
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
  end
end
