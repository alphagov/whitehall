class ContentBlockManager::ContentBlock::Document::Show::EmbeddedObjects::SubschemaItemComponent < ViewComponent::Base
  def initialize(content_block_edition:, object_type:, object_title:)
    @content_block_edition = content_block_edition
    @object_type = object_type
    @object_title = object_title
  end

private

  attr_reader :content_block_edition, :object_type, :object_title

  def metadata_items
    object.reject { |k, _v| embeddable_fields.include?(k) }
  end

  def block_items
    object.select { |k, _v| embeddable_fields.include?(k) }
  end

  def embeddable_fields
    @embeddable_fields ||= schema.embeddable_fields
  end

  def schema
    @schema ||= content_block_edition.document.schema.subschema(object_type)
  end

  def object
    @object ||= content_block_edition.details.dig(object_type, object_title)
  end
end
