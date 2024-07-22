class ContentObjectStore::ContentBlockEdition::Show::TimelineComponent < ViewComponent::Base
  include ActionView::Helpers::RecordTagHelper
  def initialize(content_block_versions:)
    @content_block_versions = content_block_versions
  end

private

  attr_reader :content_block_versions

  def items
    content_block_versions.map do |version|
      {
        title: "#{version.item.block_type.humanize} #{version.event}",
        byline: User.find_by_id(version.whodunnit).name,
        date: time_html(version.created_at),
      }
    end
  end

  def time_html(date_time)
    formatted_timestamp = date_time.strftime("%d %B %Y at %I:%M%P")
    tag.time(
      formatted_timestamp,
      class: "date",
      datetime: date_time.iso8601,
      lang: "en",
    )
  end
end
