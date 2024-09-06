module ContentObjectStore
  module ContentBlock
    class Edition < ApplicationRecord
      include Documentable
      include HasAuditTrail
      include HasAuthors
      include HasLeadOrganisation
      include ValidatesDetails
      include Workflow
    end
  end
end
