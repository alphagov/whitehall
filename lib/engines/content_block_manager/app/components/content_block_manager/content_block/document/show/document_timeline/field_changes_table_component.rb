class ContentBlockManager::ContentBlock::Document::Show::DocumentTimeline::FieldChangesTableComponent < ViewComponent::Base
  def initialize(version:)
    @version = version
  end

private

  attr_reader :version

  def rows
    version.field_diffs.map do |field|
      [
        { text: field["field_name"].humanize },
        { text: field["previous_value"] },
        { text: field["new_value"] },
      ]
    end
  end
end
