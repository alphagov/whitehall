module ContentObjectStore
  module HasAuthors
    extend ActiveSupport::Concern

    included do
      has_many :content_block_edition_authors, dependent: :destroy
    end
  end
end
