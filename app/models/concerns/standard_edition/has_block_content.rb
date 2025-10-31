module StandardEdition::HasBlockContent
  extend ActiveSupport::Concern
  included do
    validate :validate_block_content
  end

  def block_content=(value)
    value = value.is_a?(StandardEdition::BlockContent) ? value.attributes : value
    merged_values = value.is_a?(Hash) ? (block_content.to_h || {}).deep_merge(value) : value
    super(merged_values)
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
