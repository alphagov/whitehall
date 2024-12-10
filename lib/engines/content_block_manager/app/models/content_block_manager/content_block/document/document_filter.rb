module ContentBlockManager
  class ContentBlock::Document::DocumentFilter
    FILTER_ERROR = Data.define(:attribute, :full_message)

    def initialize(filters = {})
      @filters = filters
    end

    def paginated_documents
      unpaginated_documents.page(page).per(default_page_size)
    end

    def errors
      @errors ||= begin
        @errors = []
        from = validate_date(:last_updated_from)
        to = validate_date(:last_updated_to)

        if @errors.empty? && to.present? && from.present? && from.after?(to)
          @errors << FILTER_ERROR.new(attribute: "last_updated_from", full_message: I18n.t("content_block_document.index.errors.date.range.invalid"))
        end

        @errors
      end
    end

    def valid?
      errors.empty?
    end

  private

    def validate_date(key)
      return unless is_date_present?(key)

      date = date_from_filters(key)
      Time.zone.local(date[:year], date[:month], date[:day])
    rescue ArgumentError, TypeError, NoMethodError, RangeError
      @errors << FILTER_ERROR.new(attribute: key.to_s, full_message: I18n.t("content_block_document.index.errors.date.invalid", attribute: key.to_s.humanize))
      nil
    end

    def page
      @filters[:page].presence || 1
    end

    def default_page_size
      Admin::EditionFilter::GOVUK_DESIGN_SYSTEM_PER_PAGE
    end

    def is_date_present?(date_key)
      @filters[date_key].present? && @filters[date_key].any? { |_, value| value.present? }
    end

    def date_from_filters(date_key)
      filter = @filters[date_key]
      year = filter["1i"].to_i
      month = filter["2i"].to_i
      day = filter["3i"].to_i
      { year:, month:, day: }
    end

    def from_date
      @from_date ||= if is_date_present?(:last_updated_from)
                       date = date_from_filters(:last_updated_from)
                       Time.zone.local(date[:year], date[:month], date[:day])
                     end
    end

    def to_date
      @to_date ||= if is_date_present?(:last_updated_to)
                     date = date_from_filters(:last_updated_to)
                     Time.zone.local(date[:year], date[:month], date[:day]).end_of_day
                   end
    end

    def unpaginated_documents
      documents = ContentBlock::Document
      documents = documents.live
      documents = documents.joins(:latest_edition)
      documents = documents.with_keyword(@filters[:keyword]) if @filters[:keyword].present?
      documents = documents.where(block_type: @filters[:block_type]) if @filters[:block_type].present?
      documents = documents.with_lead_organisation(@filters[:lead_organisation]) if @filters[:lead_organisation].present?
      documents = documents.from_date(from_date) if valid? && from_date
      documents = documents.to_date(to_date) if valid? && to_date
      documents = documents.distinct
      documents.order("content_block_editions.updated_at DESC")
    end
  end
end
