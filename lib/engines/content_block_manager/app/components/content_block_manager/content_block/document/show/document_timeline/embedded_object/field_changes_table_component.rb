class ContentBlockManager::ContentBlock::Document::Show::DocumentTimeline::EmbeddedObject::FieldChangesTableComponent < ViewComponent::Base
  def initialize(object_id:, field_diff:, subschema_id:, content_block_edition:)
    @object_id = object_id
    @field_diff = field_diff
    @subschema_id = subschema_id
    @content_block_edition = content_block_edition
  end

private

  attr_reader :object_id, :field_diff, :subschema_id, :content_block_edition

  def rows
    field_diff.map do |field, diffs|
      [
        { text: field.humanize },
        { text: diffs.previous_value },
        { text: diffs.new_value },
      ]
    end
  end

  def caption
    content_block_edition.details.dig(subschema_id, object_id, "title") || object_id.underscore.humanize
  end
end
