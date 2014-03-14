class Frontend::StatisticalReleaseAnnouncementsFilter < FormObject
  named "StatisticalReleaseAnnouncementsFilter"
  attr_accessor :keywords,
                :from_date, :parsed_from_date,
                :to_date, :parsed_to_date,
                :page

  RESULTS_PER_PAGE = 40

  validate :validate_dates

  def to_date=(date_string)
    @to_date = date_string
    @parsed_to_date = Chronic.parse(date_string, guess: :end)
  end

  def from_date=(date_string)
    @from_date = date_string
    @parsed_from_date = Chronic.parse(date_string, guess: :begin)
  end

  def page
    @page || 1
  end

  def page=(page_number)
    if page_number.to_i > 0
      @page = page_number.to_i
    end
  end

  def valid_filter_params
    valid?
    params = {}
    params[:keywords]  = keywords         if keywords.present?
    params[:to_date]   = parsed_to_date   if parsed_to_date.present?
    params[:from_date] = parsed_from_date if parsed_from_date.present?
    params
  end

  def results
    @results ||= provider.search(valid_filter_params.merge(page: page, per_page: RESULTS_PER_PAGE))
  end

  def next_page_params
    valid_filter_params.merge(page: page + 1)
  end

  def previous_page_params
    valid_filter_params.merge(page: page - 1)
  end

  def next_page?
    results.next_page?
  end

  def prev_page?
    results.prev_page?
  end

private
  def validate_dates
    errors.add(:from_date, :invalid) if from_date.present? && parsed_from_date.nil?
    errors.add(:to_date, :invalid) if to_date.present? && parsed_to_date.nil?
  end

  def provider
    Frontend::StatisticalReleaseAnnouncementProvider
  end
end
