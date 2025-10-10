module StandardEditions
  class BlockContentType
    include ActiveModel::Validations
    validate :valid_instance_of_document_type_attributes
    validate :valid_nested_attributes

    def initialize(schema, path)
      @schema = schema
      @path = path
    end

    def attributes=(values)
      values = values.to_h
      values.each do |key, value|
        setter = "#{key}="
        if value.is_a? Hash
          nested_schema = @schema["properties"][key.to_s]
          nested_attributes = self.class.new(nested_schema, @path.push(key.to_s))
          nested_attributes.assign_attributes(value)
          public_send(setter, nested_attributes)
        else
          public_send(setter, value)
        end
      end
    end
    alias_method :assign_attributes, :attributes=

    def attributes
      @attributes ||= attributes_class_for(@schema).new
    end

  private

    def valid_instance_of_document_type_attributes
      return unless @schema.key?("validations")

      @schema["validations"].each do |key, options|
        case key
        when "presence"
          validates_with ActiveModel::Validations::PresenceValidator, options.with_indifferent_access
        else
          raise InvalidArgumentError "undefined validator type #{key}"
        end
      end
    end

    def valid_nested_attributes
      @schema["properties"].each do |key, nested_schema|
        next unless nested_schema["type"] == "object"

        nested_attribute_values = attributes.public_send(key)
        next if nested_attribute_values.valid?

        nested_attribute_values.errors.each do |error|
          errors.import(error, { attribute: "#{@path.push(key).validation_error_attribute}.#{error.attribute}" })
        end
      end
    end

    def method_missing(symbol, *args)
      if attributes.class.instance_methods.include?(symbol)
        attributes.public_send(symbol, *args)
      else
        super
      end
    end

    def respond_to_missing?(method_name)
      attributes.class.instance_methods.include?(method_name) || super
    end

    def attributes_class_for(schema)
      attributes_class = Struct.new(*schema["properties"].keys.map(&:to_sym))
      attributes_class.set_temporary_name("#{schema['title']} attributes")
      attributes_class
    end
  end
end
