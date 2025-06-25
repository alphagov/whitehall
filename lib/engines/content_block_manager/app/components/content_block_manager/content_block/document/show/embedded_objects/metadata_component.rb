class ContentBlockManager::ContentBlock::Document::Show::EmbeddedObjects::MetadataComponent < ViewComponent::Base
  include ContentBlockManager::ContentBlock::TranslationHelper
  def initialize(items:, object_type:)
    @items = items
    @object_type = object_type
  end

private

  attr_reader :items

  def rows
    items.map do |key, value|
      {
        field: humanized_label(key, @object_type),
        value: value,
      }
    end
  end
end
