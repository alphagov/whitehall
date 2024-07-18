class ContentObjectStore::ContentBlockEdition < ApplicationRecord
  include ContentObjectStore::Documentable
  include ContentObjectStore::ValidatesDetails
  include ContentObjectStore::HasAuthors
end
