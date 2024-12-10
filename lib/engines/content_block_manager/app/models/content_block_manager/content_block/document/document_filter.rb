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

    def is_date_present?(date_key)
      @filters[date_key].present? && @filters[date_key].all? { |_, value| value.present? }
    end

    def from_date
      @from_date ||= if is_date_present?(:last_updated_from)
                       filter = @filters[:last_updated_from]
                       year = filter["1i"].to_i
                       month = filter["2i"].to_i
                       day = filter["3i"].to_i
                       Time.zone.local(year, month, day)
                     end
    end

    def to_date
      @to_date ||= if is_date_present?(:last_updated_to)
                     filter = @filters[:last_updated_to]
                     year = filter["1i"].to_i
                     month = filter["2i"].to_i
                     day = filter["3i"].to_i
                     Time.zone.local(year, month, day).end_of_day
                   end
    end

    def unpaginated_documents
      documents = ContentBlock::Document
      documents = documents.live
      documents = documents.joins(:latest_edition)
      documents = documents.with_keyword(@filters[:keyword]) if @filters[:keyword].present?
      documents = documents.where(block_type: @filters[:block_type]) if @filters[:block_type].present?
      documents = documents.with_lead_organisation(@filters[:lead_organisation]) if @filters[:lead_organisation].present?
      documents = documents.from_date(from_date) if from_date
      documents = documents.to_date(to_date) if to_date
      documents.order("content_block_editions.updated_at DESC")
    end
  end
end
