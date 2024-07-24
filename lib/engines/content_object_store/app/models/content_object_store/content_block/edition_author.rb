module ContentObjectStore
  module ContentBlock
    class EditionAuthor < ApplicationRecord
      belongs_to :content_block_edition
      belongs_to :user
    end
  end
end
