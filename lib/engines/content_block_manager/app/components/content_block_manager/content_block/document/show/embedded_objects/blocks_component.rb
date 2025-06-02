class ContentBlockManager::ContentBlock::Document::Show::EmbeddedObjects::BlocksComponent < ViewComponent::Base
  include ContentBlockManager::ContentBlock::EmbedCodeHelper

  def initialize(items:, object_type:, object_title:, content_block_document:)
    @items = items
    @object_type = object_type
    @object_title = object_title
    @content_block_document = content_block_document
  end

private

  attr_reader :items, :object_type, :object_title, :content_block_document

  def rows
    items.map do |key, value|
      {
        key: key.titleize,
        value: content_for_row(key, value),
        data: data_attributes_for_row(key),
      }
    end
  end

  def content_for_row(key, value)
    content = content_tag(:p, value, class: "app-c-embedded-objects-blocks-component__content")
    content << content_tag(:p, content_block_document.embed_code_for_field("#{object_type}/#{object_title}/#{key}"), class: "app-c-embedded-objects-blocks-component__embed-code")
    content
  end

  def data_attributes_for_row(key)
    attributes = {
      testid: (object_title.parameterize + "_#{key}").underscore,
    }
    attributes.merge!(copy_embed_code_data_attributes("#{object_type}/#{object_title}/#{key}", content_block_document))
    attributes
  end

  def schema
    @schema ||= content_block_document.schema
  end
end
