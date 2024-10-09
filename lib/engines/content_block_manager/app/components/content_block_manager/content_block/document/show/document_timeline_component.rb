class ContentBlockManager::ContentBlock::Document::Show::DocumentTimelineComponent < ViewComponent::Base
  include ActionView::Helpers::RecordTagHelper
  def initialize(content_block_versions:)
    @content_block_versions = content_block_versions
  end

private

  attr_reader :content_block_versions

  def items
    content_block_versions.reject { |version| version.state.nil? }.map do |version|
      {
        title: title(version),
        byline: User.find_by_id(version.whodunnit)&.name || "unknown user",
        date: time_html(version.created_at),
      }
    end
  end

  def title(version)
    "#{version.item.block_type.humanize} #{version.state}"
  end

  def first_created_edition
    content_block_versions.last
  end

  def time_html(date_time)
    tag.time(
      I18n.l(date_time, format: :long_ordinal),
      class: "date",
      datetime: date_time.iso8601,
      lang: "en",
    )
  end
end
