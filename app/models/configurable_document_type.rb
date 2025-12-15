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

  def self.convertible_from(current_type_key)
    available_types = []
    if (group = ConfigurableDocumentType.find(current_type_key).settings["configurable_document_group"])
      available_types = ConfigurableDocumentType.where_group(group)
        .reject { |type| type.key == current_type_key }
    end
    available_types
  end

  def initialize(type)
    @key = type["key"]
    @title = type["title"]
    @description = type["description"]
    @schema = type["schema"]
    @associations = type["associations"]
    @settings = type["settings"]
  end

  def -(other)
    Diff.new(other, self)
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

  class Diff
    attr_reader :added_prop_keys, :removed_prop_keys, :added_assoc_keys, :removed_assoc_keys

    def initialize(type_a, type_b)
      @removed_prop_keys = type_a.properties.keys - type_b.properties.keys
      @added_prop_keys   = type_b.properties.keys - type_a.properties.keys
      @removed_assoc_keys = type_a.associations.map { |a| a["key"] } - type_b.associations.map { |a| a["key"] }
      @added_assoc_keys   = type_b.associations.map { |a| a["key"] } - type_a.associations.map { |a| a["key"] }
    end
  end

  class NotFoundError < StandardError
  end
end
