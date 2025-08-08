class ContentBlockManager::ContentBlock::Document::Show::EmbeddedObjects::SubschemaItemsComponent < ViewComponent::Base
  def initialize(content_block_edition:, subschema:)
    @content_block_edition = content_block_edition
    @subschema = subschema
  end

  def id
    object_type
  end

  def label
    "#{subschema.name.pluralize} (#{embedded_objects.count})"
  end

private

  attr_reader :show_button, :content_block_edition, :subschema

  def embedded_objects
    @embedded_objects ||= content_block_edition.details.fetch(object_type, {})
  end

  def object_type
    @object_type ||= subschema.id
  end
end
