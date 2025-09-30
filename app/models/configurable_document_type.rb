class ConfigurableDocumentType
  attr_reader :key, :schema, :associations, :settings

  def self.types
    @types ||= StandardEdition.subclasses.each_with_object({}) do |klass, hash|
      hash[klass.config.key] = klass
    end
  end

  def self.setup_test_types(test_types)
    @types = test_types
  end

  def self.find(type_key)
    if type_key.nil?
      raise NotFoundError, "No document type specified"
    elsif !types.key?(type_key)
      raise NotFoundError, "No document type found for '#{type_key}'"
    end

    new(types[type_key])
  end

  def self.all
    types.values.map { |type| new(type) }
  end

  def self.all_keys
    types.keys
  end

  def initialize(type)
    @type = type.config
  end

  def label
    @type.title
  end

  class NotFoundError < StandardError
  end
end
