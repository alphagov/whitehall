class ContentBlockManager::ContentBlock::Document::Show::EmbeddedObjects::MetadataComponent < ViewComponent::Base
  def initialize(items:)
    @items = items
  end

private

  attr_reader :items

  def rows
    items.map do |key, value|
      {
        field: key.titleize,
        value: value,
      }
    end
  end
end
