class ContentObjectStore::ContentBlockEdition < ApplicationRecord
  include ContentObjectStore::Identifiable
  include ContentObjectStore::ValidatesDetails
  include ContentObjectStore::HasAuthors

  validates :creator, presence: true

  def creator
    content_block_edition_authors.first&.user
  end

  def creator=(user)
    if new_record?
      content_block_edition_author = content_block_edition_authors.first || content_block_edition_authors.build
      content_block_edition_author.user = user
    else
      raise "author can only be set on new records"
    end
  end
end
