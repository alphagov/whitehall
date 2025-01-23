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

  def field_has_changed(changed_fields, field_name)

  end

  def table_rows(version)
    if version.changed_fields.present?
      changed_fields = version.changed_fields
      title_row = changed_fields.find { |field| field["field_name"] == "title" }
      org_row =  changed_fields.find { |field| field["field_name"] == "lead_organisation" }
      instructions_row =  changed_fields.find { |field| field["field_name"] == "instructions_to_publishers" }
      details_fields = changed_fields.reject { |field| %w[title lead_organisation instructions_to_publishers].include?(field["field_name"]) }

      rows = []
      rows.append([{ text: "Title" }, { text: title_row["previous"] }, { text: title_row["new"] }]) if title_row.present?
      if details_fields.present?
        details_fields.each do |field|
          rows.append([{ text: field["field_name"].humanize }, { text: field["previous"] }, { text: field["new"] }])
        end
      end
      rows.append([{ text: "Lead organisation" }, { text: org_row["previous"] }, { text: org_row["new"] }]) if org_row.present?
      rows.append([{ text: "Instructions to publishers" }, { text: instructions_row["previous"] }, { text: instructions_row["new"] }]) if instructions_row.present?
      rows.compact
    end
  end
end
