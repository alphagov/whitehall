module ContentBlockManager
  class ContentBlock::Document::DocumentFilter
    def initialize(filters = {})
      @filters = filters
    end

    def documents
      documents = ContentBlock::Document
      documents = documents.live
      documents = documents.with_title(@filters[:title]) if @filters[:title].present?
      documents
    end
  end
end
