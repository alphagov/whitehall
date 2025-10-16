class ConfigurableDocumentType
  attr_reader :key, :schema, :associations, :settings

  def self.types
    @types ||= real_types
  end

  def self.setup_test_types(test_types)
    @types = test_types
  end

  def self.find(type_key, bypass_cache: false)
    scope = bypass_cache ? real_types : types
    if type_key.nil?
      raise NotFoundError, "No document type specified"
    elsif !scope.key?(type_key)
      raise NotFoundError, "No document type found for '#{type_key}'"
    end

    new(scope[type_key])
  end

  def self.all
    types.values.map { |type| new(type) }
  end

  def self.all_keys
    types.keys
  end

  def initialize(type)
    @key = type["key"]
    @schema = type["schema"]
    @associations = type["associations"]
    @settings = type["settings"]
  end

  def label
    @schema["title"]
  end

  def properties
    @schema["properties"]
  end

  class NotFoundError < StandardError
  end

  def self.real_types
    Dir.glob("app/models/configurable_document_types/*.json").each_with_object({}) do |filename, hash|
      data = JSON.parse(File.read(filename))
      hash[data["key"]] = data
    end
  end
end
