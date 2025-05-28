class ContentBlockManager::ContentBlock::Document::Show::EmbeddedObjects::SummaryCardComponent < ViewComponent::Base
  def initialize(content_block_edition:, object_type:, object_title:)
    @content_block_edition = content_block_edition
    @object_type = object_type
    @object_title = object_title
  end

private

  attr_reader :content_block_edition, :object_type, :object_title

  def title
    "#{object_type.titleize.singularize} details"
  end

  def rows
    object.keys.map do |key|
      {
        key: key.titleize,
        value: object[key],
      }
    end
  end

  def object
    content_block_edition.block_attributes.dig(object_type, object_title)
  end
end
