class ContentBlockManager::Shared::EmbeddedObjects::SummaryCardComponent < ViewComponent::Base
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
    object.keys.map { |key|
      rows = [
        {
          key: key.titleize,
          value: object[key],
          data: data_attributes_for_row(key),
        },
      ]
      rows.push(embed_code_row(key)) if should_show_embed_code?(key)
      rows
    }.flatten
  end

  def data_attributes_for_row(key)
    attributes = {
      testid: (object_title.parameterize + "_#{key}").underscore,
    }
    attributes.merge!(copy_embed_code(key)) if should_show_embed_code?(key)
    attributes
  end

  def should_show_embed_code?(key)
    !is_editable && is_embeddable?(key)
  end

  # This generates a row containing the embed code for the field above it -
  # it will be deleted if javascript is enabled by copy-embed-code.js.
  def embed_code_row(key)
    {
      key: "Embed code",
      value: content_block_edition.document.embed_code_for_field("#{object_type}/#{object_title}/#{key}"),
      data: {
        "embed-code-row": "true",
      },
    }
  end

  def embeddable_fields
    @embeddable_fields = content_block_edition.document.schema.subschema(object_type).embeddable_fields
  end

  def is_embeddable?(key)
    embeddable_fields.include?(key)
  end

  def copy_embed_code(key)
    {
      module: "copy-embed-code",
      "embed-code": content_block_edition.document.embed_code_for_field("#{object_type}/#{object_title}/#{key}"),
    }
  end

  def object
    content_block_edition.details.dig(object_type, object_title)
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
