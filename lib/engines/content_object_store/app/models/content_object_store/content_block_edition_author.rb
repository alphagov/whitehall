class ContentObjectStore::ContentBlockEditionAuthor < ApplicationRecord
  belongs_to :content_block_edition
  belongs_to :user
end
