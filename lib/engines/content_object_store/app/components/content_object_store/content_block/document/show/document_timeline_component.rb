class ContentObjectStore::ContentBlock::Document::Show::DocumentTimelineComponent < ViewComponent::Base
  include ActionView::Helpers::RecordTagHelper
  def initialize(content_block_versions:)
    @content_block_versions = content_block_versions
  end

private

  attr_reader :content_block_versions

  def items
    content_block_versions.map do |version|
      {
        title: title(version),
        byline: User.find_by_id(version.whodunnit).name,
        date: time_html(version.created_at),
      }
    end
  end

  def title(version)
    if version.id == first_created_edition.id
      "#{version.item.block_type.humanize} created"
    else
      "#{version.item.block_type.humanize} changed"
    end
  end

  def first_created_edition
    content_block_versions.last
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
