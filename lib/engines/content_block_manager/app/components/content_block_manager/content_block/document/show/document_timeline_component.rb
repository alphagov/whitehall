class ContentBlockManager::ContentBlock::Document::Show::DocumentTimelineComponent < ViewComponent::Base
  include ActionView::Helpers::RecordTagHelper
  def initialize(content_block_versions:)
    @content_block_versions = content_block_versions
  end

private

  attr_reader :content_block_versions

  def items
    content_block_versions.reject { |version| show_to_user?(version) }.map do |version|
      {
        title: title(version),
        byline: User.find_by_id(version.whodunnit)&.then { |user| helpers.linked_author(user, { class: "govuk-link" }) } || "unknown user",
        date: time_html(version.created_at),
        table_rows: table_rows(version),
        internal_change_note: internal_change_note(version),
        change_note: change_note(version),
      }
    end
  end

  def show_to_user?(version)
    version.state.nil? || version.state == "superseded"
  end

  def title(version)
    case version.state
    when "published"
      version.state.capitalize
    when "scheduled"
      "Scheduled for publishing on #{version.item.scheduled_publication.to_fs(:long_ordinal_with_at)}"
    else
      "#{version.item.block_type.humanize} #{version.state}"
    end
  end

  def first_created_edition
    content_block_versions.last
  end

  def time_html(date_time)
    tag.time(
      date_time.to_fs(:long_ordinal_with_at),
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

  def internal_change_note(version)
    version.item.internal_change_note
  end

  def change_note(version)
    version.item.change_note
  end
end
