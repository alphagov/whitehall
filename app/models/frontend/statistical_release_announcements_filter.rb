class Frontend::StatisticalReleaseAnnouncementsFilter < FormObject
  named "StatisticalReleaseAnnouncementsFilter"
  attr_accessor :keywords,
                :from_date, :parsed_from_date,
                :to_date, :parsed_to_date

  validate :validate_dates

  def to_date=(date_string)
    @to_date = date_string
    @parsed_to_date = Chronic.parse(date_string, guess: :end)
  end

  def from_date=(date_string)
    @from_date = date_string
    @parsed_from_date = Chronic.parse(date_string, guess: :begin)
  end

  def valid_filter_params
    valid?
    params = {}
    params[:keywords]  = keywords         if keywords.present?
    params[:to_date]   = parsed_to_date   if parsed_to_date.present?
    params[:from_date] = parsed_from_date if parsed_from_date.present?
    params
  end

private
  def validate_dates
    errors.add(:from_date, :invalid) if from_date.present? && parsed_from_date.nil?
    errors.add(:to_date, :invalid) if to_date.present? && parsed_to_date.nil?
  end
end
