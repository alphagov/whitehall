module StandardEdition::HasBlockContent
  extend ActiveSupport::Concern
  included do
    validate :validate_block_content
  end

  def block_content=(value)
    current  = (as_plain_hash(self[:block_content]) || {}).deep_stringify_keys
    incoming = (as_plain_hash(value) || {}).deep_stringify_keys
    super(current.deep_merge(incoming))
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

  def as_plain_hash(value)
    case value
    when nil
      {}
    when StandardEdition::BlockContent
      # unwrap to its attributes, and recurse so nested objects become plain hashes too
      as_plain_hash(value.attributes)
    when Hash
      value.transform_values { |x| as_plain_hash(x) }
    else
      # value might be the dynamically generated "Block content attributes" object
      # defined in StandardEdition::BlockContent, or else a String, Integer, etc.
      value.respond_to?(:to_h) ? as_plain_hash(value.to_h) : value
    end
  end
end
