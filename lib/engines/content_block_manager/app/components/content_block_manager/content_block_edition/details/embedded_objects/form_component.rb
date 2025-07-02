class ContentBlockManager::ContentBlockEdition::Details::EmbeddedObjects::FormComponent < ContentBlockManager::ContentBlockEdition::Details::FormComponent
  def initialize(content_block_edition:, subschema:, params:, object_title: nil)
    @content_block_edition = content_block_edition
    @subschema = subschema
    @params = params || {}
    @object_title = object_title
  end

private

  attr_reader :content_block_edition, :subschema, :params, :object_title

  def schema
    @subschema
  end

  def component_args(field)
    {
      content_block_edition:,
      field: field,
      subschema:,
      value: params[field.name],
      object_title:,
    }.compact
  end
end
