# require 'json_schemer'
class FlexiblePageType
  @types = {}

  attr_reader :key, :schema

  class << self
    attr_accessor :types
  end

  def self.boot
    filenames = Dir.glob("app/models/flexible_page_types/*.json")
    @types = filenames.each_with_object({}) do |filename, types|
      type = JSON.parse(File.read(filename))
      types[type["key"]] = type
    end
  end

  def self.setup_test_types(types)
    @types = types
  end

  def self.find(type_key)
    new(@types[type_key])
  end

  def self.all
    @types.values.map { |type| new(type) }
  end

  def self.all_keys
    @types.keys
  end

  def initialize(type)
    @key = type["key"]
    @schema = type["schema"]
  end

  def label
    @schema["title"]
  end

  def properties
    @schema["properties"]
  end

  def validator
    JSONSchemer.schema(@schema)
  end
end
