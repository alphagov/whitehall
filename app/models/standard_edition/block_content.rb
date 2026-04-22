class StandardEdition::BlockContent
  include ActiveModel::Validations
  include ActiveModel::Validations::Callbacks
  include DateValidation

  validate :run_schema_validations

  VALIDATORS = {
    "embedded_contacts_exist" => GovspeakContactEmbedValidator,
    "length" => ActiveModel::Validations::LengthValidator,
    "no_footnotes_allowed" => NoFootnotesInGovspeakValidator,
    "presence" => ActiveModel::Validations::PresenceValidator,
    "safe_html" => SafeHtmlValidator,
    "valid_internal_path_links" => InternalPathLinksValidator,
    "social_media_links" => SocialMediaLinksValidator,
  }.freeze

  def initialize(schema, path = ConfigurableContentBlocks::Path.new)
    @schema = schema
    @path = path
    @attributes_config = schema["attributes"] || {}
  end

  def attributes=(values)
    values = values.to_h
    @attributes_config.each do |key, nested_schema|
      setter = "#{key}="
      if nested_schema["type"] == "date"
        public_send(setter, pre_validate_date_attribute(key, values[key]))
      elsif nested_schema["type"] == "array"
        #  Convert
        # { "0" => { "foo" => "bar" }, "1" => { "delete_me" => "something", "_destroy" => "1" } }
        # to
        # [ { "foo" => "bar" } ]
        array_elements = values[key].is_a?(Hash) ? values[key].values : values[key]
        public_send(setter, (array_elements || []).reject { |h| h["_destroy"] == "1" })
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

  def run_schema_validations
    @schema["validations"]&.each do |key, options|
      validator_class = VALIDATORS[key] or raise ArgumentError, "undefined validator type #{key}"
      opts = options.symbolize_keys

      on = opts.delete(:on) # Support config like: { ..., "on": "publish" }
      next if on && validation_context&.to_sym != on.to_sym

      validator_class.new(opts).validate(self)
    end

    @schema["attributes"]&.each do |attr_name, attr_schema|
      next unless attr_schema["attributes"]

      item_class = attributes_class_for(attr_schema["attributes"], attr_schema["validations"])
      (send(attr_name.to_sym) || []).each_with_index do |item, index|
        item_instance = item_class.new(item)
        next if item_instance.valid?

        item_instance.errors.each do |error|
          errors.import(error, attribute: "#{attr_name}.#{index}.#{error.attribute}".to_sym)
        end
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

  def respond_to_missing?(method_name, _include_all)
    attributes.class.instance_methods.include?(method_name) || super
  end

  def attributes_class_for(attribute_config, validations_config = nil)
    attributes_class = Class.new do
      include ActiveModel::API
      include ActiveModel::Attributes
      include ActiveModel::Serializers::JSON

      attribute_config.each do |key, property_schema|
        case property_schema["type"]
        when "object"
          attribute key
        when "array"
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

    validations_config&.each do |validator_key, options|
      attrs = Array(options["attributes"]).map(&:to_sym)
      attributes_class.validates(*attrs, validator_key.to_sym => true)
    end

    attributes_class.set_temporary_name("Block content attributes")
    attributes_class
  end
end
