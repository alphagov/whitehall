class ContentBlockManager::ContentBlock::Document::Show::DocumentTimeline::EmbeddedObject::FieldChangesTableComponent < ViewComponent::Base
  def initialize(object_id:, field_diff:, subschema_id:, content_block_edition:)
    @object_id = object_id
    @field_diff = field_diff
    @subschema_id = subschema_id
    @content_block_edition = content_block_edition
  end

  def field_diff
    flatten_hash_from(@field_diff)
  end

private

  attr_reader :object_id, :subschema_id, :content_block_edition

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

  def flatten_hash_from(hash)
    hash.each_with_object({}) do |(key, value), memo|
      if value.is_a? Hash
        next flatten_hash_from(value).each do |k, v|
          memo["#{key}_#{k}"] = v
        end
      end
      memo[key] = value
    end
  end
end
