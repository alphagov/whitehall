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
      field: field,
      object_id: object_title,
      value: params[field.name],
    }.compact
  end
end
