class ContentBlockManager::Shared::EmbeddedObjects::SummaryCardComponent < ViewComponent::Base
  include ContentBlockManager::ContentBlock::EmbedCodeHelper
  def initialize(content_block_edition:, object_type:, object_title:, is_editable: false, redirect_url: nil)
    @content_block_edition = content_block_edition
    @object_type = object_type
    @object_title = object_title
    @is_editable = is_editable
    @redirect_url = redirect_url
  end

private

  attr_reader :content_block_edition, :object_type, :object_title, :is_editable, :redirect_url

  def title
    "#{object_type.titleize.singularize} details"
  end

  def rows
    schema.fields.map { |field|
      key = field.name
      rows = [
        {
          key: key.titleize,
          value: object[key],
          data: data_attributes_for_row(key),
        },
      ]
      rows.push(embed_code_row("#{object_type}/#{object_title}/#{key}", content_block_edition.document)) if should_show_embed_code?(key)
      rows
    }.flatten
  end

  def data_attributes_for_row(key)
    attributes = {
      testid: (object_title.parameterize + "_#{key}").underscore,
    }
    attributes.merge!(copy_embed_code_data_attributes("#{object_type}/#{object_title}/#{key}", content_block_edition.document)) if should_show_embed_code?(key)
    attributes
  end

  def should_show_embed_code?(key)
    !is_editable && is_embeddable?(key)
  end

  def embeddable_fields
    @embeddable_fields = schema.embeddable_fields
  end

  def is_embeddable?(key)
    embeddable_fields.include?(key)
  end

  def object
    content_block_edition.block_attributes.dig(object_type, object_title)
  end

  def schema
    @schema ||= content_block_edition.document.schema.subschema(object_type)
  end

  def summary_card_actions
    if is_editable
      [
        {
          label: "Edit",
          href: helpers.content_block_manager.edit_embedded_object_content_block_manager_content_block_edition_path(
            content_block_edition,
            object_type:,
            object_title:,
            redirect_url:,
          ),
        },
      ]
    else
      []
    end
  end
end
