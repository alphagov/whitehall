class Frontend::StatisticsAnnouncement < InflatableModel
  attr_accessor :slug, :title, :summary,
                :publication, :document_type,
                :release_date, :display_date, :release_date_confirmed,
                :release_date_change_note, :previous_display_date,
                :organisations, :topics,
                :state, :cancellation_reason, :cancellation_date

  def cancelled?
    state == "cancelled"
  end

  def release_date=(date_value)
    @release_date = parse_date(date_value)
  end

  def cancellation_date=(date_value)
    @cancellation_date = parse_date(date_value)
  end

  def display_date_with_status
    "#{display_date} (#{state})"
  end

  def to_partial_path
    "statistics_announcement"
  end

  def to_param
    slug
  end

  def national_statistic?
    document_type == "National Statistics"
  end

private

  def parse_date(date_value)
    date_value.is_a?(String) ? Time.zone.parse(date_value) : date_value
  end
end
