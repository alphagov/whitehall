module ContentBlockManager
  module ContentBlock
    class Edition < ApplicationRecord
      include Documentable
      include HasAuditTrail
      include HasAuthors
      include HasLeadOrganisation
      include ValidatesDetails
      include Workflow

      scope :current_versions, lambda {
        joins(
          "LEFT JOIN content_block_documents document ON document.latest_edition_id = content_block_editions.id",
        ).where(state: "published")
      }

      def update_document_reference_to_latest_edition!
        document.update!(latest_edition_id: id)
      end

      def render
        ContentBlockTools::ContentBlock.new(
          document_type: "content_block_#{block_type}",
          content_id: document.content_id,
          title:,
          details:,
        ).render
      end
    end
  end
end
