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

  def govspeak_enabled?
    subschema.govspeak_enabled?(nested_object_key: nested_object_key, field_name: field.name)
  end

  def id_attribute
    "#{PARENT_CLASS}_details_#{subschema_block_type}_#{nested_object_key}_#{field.name}"
  end

  def aria_described_by
    "#{id_attribute}-hint"
  end

  def hint_text
    return nil unless govspeak_enabled?

    "Govspeak supported"
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

  def error_items
    errors_for(
      content_block_edition.errors,
      "details_#{subschema_block_type}_#{nested_object_key}_#{field.name}".to_sym,
    )
  end
end
