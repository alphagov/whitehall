module ContentObjectStore
  module ContentBlock
    class Edition < ApplicationRecord
      include ContentObjectStore::Documentable
      include ContentObjectStore::ValidatesDetails
      include ContentObjectStore::HasAuthors
      include ContentObjectStore::HasAuditTrail
    end
  end
end
