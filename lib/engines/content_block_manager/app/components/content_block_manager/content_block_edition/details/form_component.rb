class ContentBlockManager::ContentBlockEdition::Details::FormComponent < ViewComponent::Base
  def initialize(content_block_edition:, schema:)
    @content_block_edition = content_block_edition
    @schema = schema
  end

private

  attr_reader :content_block_edition, :schema

  def component_for_field(field)
    format = @schema.body.dig("properties", field, "type")
    if format == "string"
      enum = @schema.body.dig("properties", field, "enum")
      if enum
        ContentBlockManager::ContentBlockEdition::Details::Fields::EnumComponent.new(
          **component_args(field).merge(enum:),
        )
      else
        ContentBlockManager::ContentBlockEdition::Details::Fields::StringComponent.new(
          **component_args(field).merge(prefix: prefix_for_field(field)).compact,
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

  def prefix_for_field(field)
    @schema.config_for_field(field).dig("field_args", "prefix")
  end
end
