module ContentBlockManager
  module ContentBlock::Edition::HasAuthors
    extend ActiveSupport::Concern
    include ContentBlock::Edition::HasCreator

    included do
      has_many :edition_authors, dependent: :destroy, class_name: "ContentBlockManager::ContentBlock::EditionAuthor"
    end
  end
end
