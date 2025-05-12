class ContentBlockManager::ContentBlockEdition::Details::FormComponent < ViewComponent::Base
  def initialize(content_block_edition:, schema:)
    @content_block_edition = content_block_edition
    @schema = schema
  end

private

  attr_reader :content_block_edition, :schema

  def component_for_field(field)
    format = @schema.body.dig("properties", field.name, "type")
    if format == "string"
      enum = @schema.body.dig("properties", field.name, "enum")
      if enum
        ContentBlockManager::ContentBlockEdition::Details::Fields::EnumComponent.new(
          **component_args(field).merge(enum:),
        )
      else
        ContentBlockManager::ContentBlockEdition::Details::Fields::StringComponent.new(
          **component_args(field),
        )
      end
    end
  end

  def component_args(field)
    {
      content_block_edition:,
      field:,
    }
  end
end
