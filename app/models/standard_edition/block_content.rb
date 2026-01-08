class StandardEdition::BlockContent
  include ActiveModel::Validations
  include ActiveModel::Validations::Callbacks
  include DateValidation

  validate :valid_instance_of_document_type_attributes
  # validate :valid_nested_attributes

  VALIDATORS = {
    "embedded_contacts_exist" => GovspeakContactEmbedValidator,
    "length" => ActiveModel::Validations::LengthValidator,
    "no_footnotes_allowed" => NoFootnotesInGovspeakValidator,
    "presence" => ActiveModel::Validations::PresenceValidator,
    "safe_html" => SafeHtmlValidator,
    "valid_internal_path_links" => InternalPathLinksValidator,
    "duration" => DurationValidator,
  }.freeze

  def initialize(schema, path = ConfigurableContentBlocks::Path.new)
    @schema = schema
    @path = path
    @attributes_config = schema["attributes"] || {}
  end

  def attributes=(values)
    # byebug if values.keys.include?("meta")
    values = values.to_h
    @attributes_config.each do |key, nested_schema|
      setter = "#{key}="
      # if nested_schema["type"] == "object"
      #   nested_attributes = self.class.new(nested_schema, @path.push(key))
      #   nested_attributes.assign_attributes(values[key])
      #   public_send(setter, nested_attributes)
      if nested_schema["type"] == "date"
        public_send(setter, pre_validate_date_attribute(key, values[key]))
      else
        public_send(setter, values[key])
      end
    end
  end
  alias_method :assign_attributes, :attributes=

  def attributes
    @attributes ||= attributes_class_for(@attributes_config).new
  end

  delegate :to_h, to: :attributes

private

  def valid_instance_of_document_type_attributes
    return unless @schema.key?("validations")

    @schema["validations"].each do |key, options|
      raise ArgumentError, "undefined validator type #{key}" unless VALIDATORS.key?(key)

      validates_with VALIDATORS[key], options.symbolize_keys
    end
  end

  # def valid_nested_attributes
  #   @attributes_config.each do |key, nested_schema|
  #     next unless nested_schema["type"] == "object"

  #     nested_attribute_values = attributes.public_send(key)
  #     next if nested_attribute_values.valid?

  #     nested_attribute_values.errors.each do |error|
  #       errors.import(error, { attribute: "#{@path.push(key).validation_error_attribute}.#{error.attribute}" })
  #     end
  #   end
  # end

  def method_missing(symbol, *args)
    if attributes.class.instance_methods.include?(symbol)
      attributes.public_send(symbol, *args)
    else
      super
    end
  end

  def respond_to_missing?(method_name, _include_all)
    attributes.class.instance_methods.include?(method_name) || super
  end

  def attributes_class_for(attribute_config)
    attributes_class = Class.new do
      include ActiveModel::API
      include ActiveModel::Attributes
      include ActiveModel::Serializers::JSON

      attribute_config.each do |key, property_schema|
        case property_schema["type"]
        when "object"
          attribute key
        else
          attribute key, property_schema["type"].to_sym
        end
      end

      delegate :[], to: :attributes

      def to_h
        attributes
      end
    end
    attributes_class.set_temporary_name("Block content attributes")
    attributes_class
  end
end
