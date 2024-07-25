module ContentObjectStore
  module HasAuthors
    extend ActiveSupport::Concern
    include ContentObjectStore::HasCreator

    included do
      has_many :edition_authors, dependent: :destroy, class_name: "ContentObjectStore::ContentBlock::EditionAuthor"
    end
  end
end
