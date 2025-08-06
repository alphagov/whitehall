class ContentBlockManager::ContentBlockEdition::Details::Fields::GovspeakEnabledTextareaComponent < ContentBlockManager::ContentBlockEdition::Details::Fields::BaseComponent
  def initialize(content_block_edition:, value:, nested_object_key:, field:, subschema:)
    @nested_object_key = nested_object_key
    @field = field
    @value = value
    @content_block_edition = content_block_edition

    super(
      subschema: subschema,
      content_block_edition: content_block_edition,
      field: field,
      value: value,
    )
  end

  attr_reader :content_block_edition, :nested_object_key, :field, :subschema, :errors

  def id_attribute
    "#{PARENT_CLASS}_details_#{subschema_block_type}_#{nested_object_key}_#{field.name}"
  end

  def label
    helpers.humanized_label(
      relative_key: field.name,
      root_object: "#{subschema_block_type}.#{nested_object_key}",
    )
  end

  def name_attribute
    "content_block/edition[details][#{subschema_block_type}][#{nested_object_key}][#{field.name}]"
  end

  def value_or_default
    value_for_field(field) || field.default_value
  end

  def error_items
    errors_for(
      content_block_edition.errors,
      "details_#{subschema_block_type}_#{nested_object_key}_#{field.name}".to_sym,
    )
  end

private

  def value_for_field(field)
    value&.fetch(field.name, nil)
  end
end
