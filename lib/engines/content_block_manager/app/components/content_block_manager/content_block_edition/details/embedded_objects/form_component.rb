class ContentBlockManager::ContentBlockEdition::Details::EmbeddedObjects::FormComponent < ContentBlockManager::ContentBlockEdition::Details::FormComponent
  def initialize(content_block_edition:, schema:, object_name:, params:, prefix: nil)
    @content_block_edition = content_block_edition
    @schema = schema
    @object_name = object_name
    @params = params || {}
    @prefix = prefix
  end

private

  attr_reader :content_block_edition, :schema, :object_name, :params

  def component_args(field)
    {
      content_block_edition:,
      label: field.humanize,
      field: [object_name, field],
      id_suffix: "#{object_name}_#{field}",
      value: params[field],
    }
  end
end
