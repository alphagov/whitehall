class FlexiblePageType
  attr_reader :key, :schema, :settings

  def self.types
    @types ||= Dir.glob("app/models/flexible_page_types/*.json").each_with_object({}) do |filename, hash|
      data = JSON.parse(File.read(filename))
      hash[data["key"]] = data
    end
  end

  def self.setup_test_types(test_types)
    @types = test_types
  end

  def self.find(type_key)
    new(types[type_key])
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
    @settings = type["settings"]
  end

  def label
    @schema["title"]
  end

  def properties
    @schema["properties"]
  end
end
