module ContentObjectStore
  module ContentBlock
    class Edition < ApplicationRecord
      include Documentable
      include HasAuditTrail
      include HasAuthors
      include HasLeadOrganisation
      include ValidatesDetails
      include Workflow

      def update_document_reference_to_latest_edition!
        document.update!(latest_edition_id: id)
      end
    end
  end
end
