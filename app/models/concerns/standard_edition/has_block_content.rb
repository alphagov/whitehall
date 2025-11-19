module StandardEdition::HasBlockContent
  extend ActiveSupport::Concern
  included do
    validate :validate_block_content
  end

  def block_content=(value)
    value_to_merge = (value || {}).to_h.deep_stringify_keys
    merged_value = (self[:block_content] || {}).deep_merge(value_to_merge)
    super(merged_value)
  end

  def block_content
    return nil if super.nil?

    @block_content ||= StandardEdition::BlockContent.new(type_instance.schema)
    @block_content.assign_attributes(super)
    @block_content
  end

private

  def validate_block_content
    unless block_content.valid?
      block_content.errors.each do |error|
        errors.import(error, { attribute: error.attribute.to_s })
      end
    end
  end
end
