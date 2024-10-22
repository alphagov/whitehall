module ContentBlockManager
  class ContentBlock::Document::DocumentFilter
    def initialize(filters = {})
      @filters = filters
    end

    def documents
      documents = ContentBlock::Document
      documents = documents.live
      documents = documents.with_keyword(@filters[:keyword]) if @filters[:keyword].present?
      documents
    end
  end
end
