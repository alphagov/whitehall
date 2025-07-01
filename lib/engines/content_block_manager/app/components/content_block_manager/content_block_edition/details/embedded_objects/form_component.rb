class ContentBlockManager::ContentBlockEdition::Details::EmbeddedObjects::FormComponent < ContentBlockManager::ContentBlockEdition::Details::FormComponent
  def initialize(content_block_edition:, subschema:, params:)
    @content_block_edition = content_block_edition
    @subschema = subschema
    @params = params || {}
  end

private

  attr_reader :content_block_edition, :subschema, :params

  def schema
    @subschema
  end

  def component_args(field)
    {
      content_block_edition:,
      field: field,
      subschema:,
      value: params[field.name],
    }.compact
  end
end
