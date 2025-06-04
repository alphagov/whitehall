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

  def component_classes
    [
      "app-c-embedded-objects-blocks-component",
      ("app-c-embedded-objects-blocks-component--with-block" if schema.embeddable_as_block?),
    ].compact.join(" ")
  end

  def summary_card_rows
    if schema.embeddable_as_block?
      [block_row]
    else
      attribute_rows
    end
  end

  def attribute_rows(key_name = :key)
    items.map do |key, value|
      {
        "#{key_name}": key.titleize,
        value: content_for_row(key, value),
        data: data_attributes_for_row(key),
      }
    end
  end

  def object_name
    object_type.singularize.humanize.downcase
  end

  def block_row
    {
      key: object_type.singularize.titleize,
      value: content_for_block_row,
      data: data_attributes_for_block_row,
    }
  end

  def content_for_row(key, value)
    content = content_tag(:p, value, class: "app-c-embedded-objects-blocks-component__content")
    content << content_tag(:p, content_block_document.embed_code_for_field("#{object_type}/#{object_title}/#{key}"), class: "app-c-embedded-objects-blocks-component__embed-code")
    content
  end

  def data_attributes_for_row(key)
    {
      testid: (object_title.parameterize + "_#{key}").underscore,
      **copy_embed_code_data_attributes("#{object_type}/#{object_title}/#{key}", content_block_document),
    }
  end

  def content_for_block_row
    content = content_tag(:div,
                          content_block_edition.render(content_block_document.embed_code_for_field("#{object_type}/#{object_title}")),
                          class: "app-c-embedded-objects-blocks-component__content")
    content << content_tag(:p, content_block_document.embed_code_for_field("#{object_type}/#{object_title}"), class: "app-c-embedded-objects-blocks-component__embed-code")
    content
  end

  def data_attributes_for_block_row
    {
      testid: object_title.parameterize.underscore,
      **copy_embed_code_data_attributes("#{object_type}/#{object_title}", content_block_document),
    }
  end

  def schema
    @schema ||= content_block_document.schema.subschema(object_type)
  end

  def content_block_edition
    @content_block_edition ||= content_block_document.latest_edition
  end
end
