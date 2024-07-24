module ContentObjectStore
  module ContentBlock
    class EditionAuthor < ApplicationRecord
      belongs_to :edition
      belongs_to :user
    end
  end
end
