module StandardEditions
  # The getter, setter and after_find callback defined here are required to work around https://github.com/globalize/globalize/issues/611
  module BlockContent
    extend ActiveSupport::Concern
    included do
      after_find :cast_block_content
      validate :validate_block_content
    end

    def block_content=(value)
      @block_content_shim ||= StandardEditions::BlockContentType.new(type_instance.schema, ConfigurableContentBlocks::Path.new)
      value = value.is_a?(StandardEditions::BlockContentType) ? value.attributes : value
      @block_content_shim.assign_attributes(value)
      super(value)
    end

    def block_content
      return nil if super.nil?

      @block_content_shim.assign_attributes(super)
      @block_content_shim
    end

  private

    def cast_block_content
      @block_content_shim ||= StandardEditions::BlockContentType.new(type_instance.schema, ConfigurableContentBlocks::Path.new)
      @block_content_shim.assign_attributes(self[:block_content]) unless self[:block_content].nil?
    end

    def validate_block_content
      unless block_content.valid?
        block_content.errors.each do |error|
          errors.import(error, { attribute: error.attribute.to_s })
        end
      end
    end
  end
end
