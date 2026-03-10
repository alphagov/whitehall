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
    unless block_content.valid?(validation_context)
      block_content.errors.each do |error|
        errors.import(error, { attribute: error.attribute.to_s })
      end
    end
  end
end
