class ContentBlockManager::ContentBlock::Document::Show::DocumentTimeline::FieldChangesTableComponent < ViewComponent::Base
  def initialize(version:, schema:)
    @version = version
    @schema = schema
  end

private

  attr_reader :version, :schema

  def rows
    rows = []
    rows.push(title_row) if version.field_diffs["title"]
    rows.push(*details_rows)
    rows.push(organisation_row) if version.field_diffs["lead_organisation"]
    rows.push(instructions_to_publishers_row) if version.field_diffs["instructions_to_publishers"]
    rows.compact
  end

  def title_row
    [
      { text: "Title" },
      { text: version.field_diffs["title"].previous_value },
      { text: version.field_diffs["title"].new_value },
    ]
  end

  def organisation_row
    [
      { text: "Lead organisation" },
      { text: version.field_diffs["lead_organisation"].previous_value },
      { text: version.field_diffs["lead_organisation"].new_value },
    ]
  end

  def details_rows
    schema.fields.map do |field|
      field_diff = version.field_diffs.dig("details", field)
      next unless field_diff

      [
        { text: field.humanize },
        { text: field_diff.previous_value },
        { text: field_diff.new_value },
      ]
    end
  end

  def instructions_to_publishers_row
    [
      { text: "Instructions to publishers" },
      { text: version.field_diffs["instructions_to_publishers"].previous_value },
      { text: version.field_diffs["instructions_to_publishers"].new_value },
    ]
  end
end
