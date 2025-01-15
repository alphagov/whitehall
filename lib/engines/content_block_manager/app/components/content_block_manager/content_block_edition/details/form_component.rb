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
      ContentBlockManager::ContentBlockEdition::Details::Fields::StringComponent.new(
        content_block_edition:,
        field:,
      )
    end
  end
end
