class ContentBlockManager::ContentBlock::Document::Show::EmbeddedObjects::MetadataComponent < ViewComponent::Base
  include ContentBlockManager::ContentBlock::TranslationHelper
  def initialize(items:, object_type:, schema:)
    @items = items
    @object_type = object_type
    @schema = schema
  end

private

  attr_reader :items

  def rows
    unordered_rows.sort_by { |row| row_ordering_rule(row) }
  end

  def unordered_rows
    items.map do |key, value|
      {
        field: humanized_label(key, @object_type),
        value: translated_value(value),
      }
    end
  end

  def row_ordering_rule(row)
    if field_order
      # If a field order is found in the config, order by the index. If a field is not found, put it to the end
      field_order.index(row.fetch(:field).downcase) || Float::INFINITY
    else
      # By default, order with title first
      row.fetch(:field).downcase == "title" ? 0 : 1
    end
  end

  def field_order
    @schema.config["field_order"]
  end
end
