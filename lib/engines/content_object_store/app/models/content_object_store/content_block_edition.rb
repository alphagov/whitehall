class ContentObjectStore::ContentBlockEdition < ApplicationRecord
  include ContentObjectStore::Identifiable
  include ContentObjectStore::ValidatesDetails
  include ContentObjectStore::HasAuthors
end
