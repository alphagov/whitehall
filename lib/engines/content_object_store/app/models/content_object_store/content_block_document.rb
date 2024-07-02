class ContentObjectStore::ContentBlockDocument < ApplicationRecord
  SCHEMA_PREFIX = "content_block".freeze

  has_many :content_block_editions,
           -> { order(created_at: :asc, id: :asc) },
           inverse_of: :content_block_document

  attr_readonly :block_type
end
