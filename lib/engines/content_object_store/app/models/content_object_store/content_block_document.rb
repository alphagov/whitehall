class ContentObjectStore::ContentBlockDocument < ApplicationRecord
  has_many :content_block_editions,
           -> { order(created_at: :asc, id: :asc) },
           inverse_of: :content_block_document

  enum :block_type, ContentObjectStore::ContentBlockSchema.valid_schemas.index_with(&:to_s)
  attr_readonly :block_type
end
