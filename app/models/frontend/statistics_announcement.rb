class Frontend::StatisticsAnnouncement < InflatableModel
  attr_accessor :slug, :title, :summary,
                :publication, :document_type,
                :release_date, :release_date_text,
                :organisations, :topics

  def release_date=(date_value)
    date_value = Time.zone.parse(date_value) if date_value.is_a? String
    @release_date = date_value
  end

  def to_partial_path
    "statistics_announcement"
  end

  def to_param
    slug
  end
end
