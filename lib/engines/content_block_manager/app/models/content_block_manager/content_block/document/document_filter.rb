module ContentBlockManager
  class ContentBlock::Document::DocumentFilter
    def initialize(filters = {})
      @filters = filters
    end

    def paginated_documents
      unpaginated_documents.page(page).per(default_page_size)
    end

  private

    def page
      @filters[:page].presence || 1
    end

    def default_page_size
      Admin::EditionFilter::GOVUK_DESIGN_SYSTEM_PER_PAGE
    end

    def unpaginated_documents
      documents = ContentBlock::Document
      documents = documents.live
      documents = documents.joins(:latest_edition)
      documents = documents.with_keyword(@filters[:keyword]) if @filters[:keyword].present?
      documents = documents.where(block_type: @filters[:block_type]) if @filters[:block_type].present?
      documents = documents.with_lead_organisation(@filters[:lead_organisation]) if @filters[:lead_organisation].present?
      documents.order("content_block_editions.updated_at DESC")
    end
  end
end
