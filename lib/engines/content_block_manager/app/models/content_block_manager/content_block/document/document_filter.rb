module ContentBlockManager
  class ContentBlock::Document::DocumentFilter
    def initialize(filters = {})
      @filters = filters
    end

    def documents
      documents = ContentBlock::Document
      documents = documents.live
      documents = documents.with_keyword(@filters[:keyword]) if @filters[:keyword].present?
      documents = documents.where(block_type: @filters[:block_type]) if @filters[:block_type].present?
      documents = documents.with_lead_organisation(@filters[:lead_organisation]) if @filters[:lead_organisation].present?
      documents
    end
  end
end
