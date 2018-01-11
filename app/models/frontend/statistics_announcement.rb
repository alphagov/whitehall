# Presenter used by `StatisticsAnnouncementProvider` to present a document
# fetched from Rummager for display on the statistics announcement index page.
class Frontend::StatisticsAnnouncement
  attr_accessor :slug, :title, :summary,
                :publication, :document_type,
                :display_date, :release_date_confirmed,
                :release_date_change_note, :previous_display_date,
                :organisations, :state, :cancellation_reason

  attr_reader :release_date, :cancellation_date

  # DID YOU MEAN: Policy Area?
  # "Policy area" is the newer name for "topic"
  # (https://www.gov.uk/government/topics)
  # "Topic" is the newer name for "specialist sector"
  # (https://www.gov.uk/topic)
  # You can help improve this code by renaming all usages of this field to use
  # the new terminology.
  attr_accessor :topics

  def initialize(attrs = {})
    attrs = Hash(attrs)
    attrs.each do |key, value|
      self.send("#{key}=", value)
    end
  end

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
