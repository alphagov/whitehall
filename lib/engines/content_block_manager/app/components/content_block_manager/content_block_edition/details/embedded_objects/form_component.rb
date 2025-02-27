class ContentBlockManager::ContentBlockEdition::Details::EmbeddedObjects::FormComponent < ContentBlockManager::ContentBlockEdition::Details::FormComponent
  def initialize(content_block_edition:, schema:, object_title:, params:)
    @content_block_edition = content_block_edition
    @schema = schema
    @object_title = object_title
    @params = params || {}
  end

private

  attr_reader :content_block_edition, :schema, :object_title, :params

  def component_args(field)
    {
      content_block_edition:,
      label: field.humanize,
      field: [object_title, field],
      id_suffix: "#{object_title}_#{field}",
      value: params[field],
    }
  end
end
