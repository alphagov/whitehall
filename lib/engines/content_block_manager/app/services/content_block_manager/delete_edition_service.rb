module ContentBlockManager
  class DeleteEditionService
    def call(content_block_edition)
      if content_block_edition.draft?
        document = content_block_edition.document
        document.with_lock do
          content_block_edition.destroy!
          if document_has_no_more_editions?(document)
            document.destroy!
          end
        end
      else
        raise ArgumentError, "Could not delete Content Block Edition #{content_block_edition.id} because it is not in draft"
      end
    end

  private

    def document_has_no_more_editions?(document)
      document.editions.count.zero?
    end
  end
end
