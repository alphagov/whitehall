module ContentObjectStore
  module ContentBlock
    class Edition < ApplicationRecord
      include ContentObjectStore::Documentable
      include ContentObjectStore::ValidatesDetails
      include ContentObjectStore::HasAuthors
      include ContentObjectStore::HasAuditTrail
      include ContentObjectStore::Workflow
      include ContentObjectStore::HasLeadOrganisation
    end
  end
end
