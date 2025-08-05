class ContentBlockManager::Shared::EmbeddedObjects::SummaryCard::NestedItemComponent < ViewComponent::Base
  include ContentBlockManager::ContentBlock::TranslationHelper
  include ContentBlockManager::ContentBlock::GovspeakHelper

  with_collection_parameter :nested_items

  def initialize(nested_items:, object_key:, title:, subschema:, nested_items_counter: nil)
    @nested_items = nested_items
    @object_key = object_key
    @title = title
    @subschema = subschema
    @nested_items_counter = nested_items_counter
  end

private

  attr_reader :nested_items, :object_key, :subschema, :nested_items_counter

  def title
    if @nested_items_counter
      "#{@title} #{@nested_items_counter + 1}"
    else
      @title
    end
  end

  def rows
    nested_items.map do |field_name, value|
      {
        key: humanized_label(relative_key: field_name),
        value: render_govspeak_if_enabled_for_field(
          object_key: object_key,
          field_name: field_name,
          value: translated_value(field_name, value),
        ),
      }
    end
  end
end
