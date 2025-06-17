class ContentBlockManager::Shared::EmbeddedObjects::SummaryCardComponent < ViewComponent::Base
  def initialize(content_block_edition:, object_type:, object_title:, redirect_url: nil)
    @content_block_edition = content_block_edition
    @object_type = object_type
    @object_title = object_title
    @redirect_url = redirect_url
  end

private

  attr_reader :content_block_edition, :object_type, :object_title, :redirect_url

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
      rows
    }.flatten
  end

  def data_attributes_for_row(key)
    attributes = {
      testid: (object_title.parameterize + "_#{key}").underscore,
    }
    attributes
  end
  end

  def embeddable_fields
    @embeddable_fields = schema.embeddable_fields
  end

  def object
    content_block_edition.details.dig(object_type, object_title)
  end

  def schema
    @schema ||= content_block_edition.document.schema.subschema(object_type)
  end

  def summary_card_actions
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
  end
end
