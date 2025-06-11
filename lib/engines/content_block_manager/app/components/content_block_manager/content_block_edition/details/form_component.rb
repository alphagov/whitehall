class ContentBlockManager::ContentBlockEdition::Details::FormComponent < ViewComponent::Base
  def initialize(content_block_edition:, schema:)
    @content_block_edition = content_block_edition
    @schema = schema
  end

private

  attr_reader :content_block_edition, :schema

  def component_for_field(field)
    args = component_args(field).merge(
      enum: field.enum_values,
      default: field.default_value
    )

    field.component_class.new(**args.compact)
  end

  def component_args(field)
    {
      content_block_edition:,
      field:,
      value: content_block_edition.details&.fetch(field.name, nil),
    }
  end
end
