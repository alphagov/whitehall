module ConfigurableDocumentTypes
  class BaseProperties
    include ActiveModel::Attributes
    include ActiveModel::AttributeAssignment
    include ActiveModel::Validations
    @attribute_blocks = {}
    @attributes_with_headings = []

    class << self
      attr_accessor :attributes_with_headings
      def block_attribute(name, &block)
        block_attribute = BlockAttribute.new(name, &block)
        @attribute_blocks[name] = block_attribute
        @attributes_with_headings << name if block_attribute.extract_headings
        attribute(name, block_attribute.cast_type, block_attribute.attribute_options)
      end

      def block_for_attribute(attribute_name)
        @attribute_blocks[attribute_name.to_sym].block
      end

      def attribute_required?(attribute_name)
        self.validators_on(attribute_name).map(&:class).include?(ActiveModel::Validations::PresenceValidator)
      end
    end
  end
end
