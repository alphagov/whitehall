module StandardEdition::HasBlockContent
  extend ActiveSupport::Concern
  included do
    validate :validate_block_content
  end

  def block_content=(value)
    value_to_merge = (value || {}).to_h.deep_stringify_keys
    merged_value = (self[:block_content] || {}).deep_merge(value_to_merge)

    normalised = make_block_content
    normalised.assign_attributes(merged_value)

    @block_content = normalised # keep the memoized object in sync
    super(normalised.to_h)
  end

  def block_content(locale = nil)
    selected_locale = locale.presence || Globalize.locale
    return nil if super(selected_locale).nil?

    @block_content ||= make_block_content
    @block_content.assign_attributes(super(selected_locale))
    @block_content
  end

private

  def make_block_content
    if type_instance.schema.is_a?(ConfigurableDocumentTypeConfig::BlockContentSchema)
      type_instance.schema
    else
      StandardEdition::BlockContent.new(type_instance.schema)
    end
  end

  def validate_block_content
    content_for_validation = current_tab_context.present? ? scoped_block_content : block_content

    unless content_for_validation.valid?(validation_context)
      content_for_validation.errors.each do |error|
        errors.import(error, attribute: error.attribute.to_s)
      end
    end
  end

  def scoped_block_content
    form_config = type_instance.form(current_tab_context)
    raise ArgumentError, "Unknown tab key '#{current_tab_context}'" unless form_config

    field_keys = form_config["fields"]&.keys || []
    schema = type_instance.schema_for_fields(field_keys)

    StandardEdition::BlockContent.new(schema).tap do |block_content|
      block_content.assign_attributes(self[:block_content] || {})
    end
  end
end
