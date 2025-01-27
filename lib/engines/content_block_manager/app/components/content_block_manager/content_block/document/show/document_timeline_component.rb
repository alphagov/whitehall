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
        byline: User.find_by_id(version.whodunnit)&.then { |user| helpers.linked_author(user, { class: "govuk-link" }) } || "unknown user",
        date: time_html(version.created_at),
        table_rows: table_rows(version),
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

  def table_rows(version)
    if version.field_diffs.present?
      version.field_diffs.map do |field|
        [
          { text: field["field_name"].humanize },
          { text: field["previous_value"] },
          { text: field["new_value"] },
        ]
      end
    end
  end
end
