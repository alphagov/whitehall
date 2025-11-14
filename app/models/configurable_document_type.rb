class ConfigurableDocumentType
  attr_reader :key, :description, :schema, :associations, :settings

  @types_mutex = Mutex.new

  def self.types
    return @types if @types

    @types_mutex.synchronize do
      return @types if @types

      @types = Dir.glob("app/models/configurable_document_types/*.json").each_with_object({}) do |filename, hash|
        data = JSON.parse(File.read(filename))
        hash[data["key"]] = data
      end
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

  def self.where_group(group)
    return all if group == "all"

    all.filter { |t| t.settings["configurable_document_group"] == group }
  end

  def initialize(type)
    @key = type["key"]
    @title = type["title"]
    @description = type["description"]
    @schema = type["schema"]
    @associations = type["associations"]
    @settings = type["settings"]
  end

  def label
    @title
  end

  def properties
    @schema["properties"]
  end

  def properties_for_edit_screen(edit_screen)
    edit_screens = @settings["edit_screens"] || {}
    return [] unless edit_screens.key?(edit_screen)

    edit_screens[edit_screen].index_with { |key| properties[key] }
  end

  class NotFoundError < StandardError
  end
end
