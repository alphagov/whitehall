class ContentBlockManager::ContentBlock::Document::Show::EmbeddedObjects::SummaryCardsComponent < ViewComponent::Base
  def initialize(content_block_document:, object_type:)
    @content_block_edition = content_block_document.latest_edition
    @object_type = object_type
  end

private

  attr_reader :content_block_edition, :object_type

  def embedded_objects
    content_block_edition.details.fetch(object_type, {})
  end
end
