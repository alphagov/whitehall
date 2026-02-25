class ConfigurableDocumentType
  attr_reader :key, :description, :schema, :associations, :settings

  CONTENT_BLOCKS = {
    "default_string" => ConfigurableContentBlocks::DefaultString,
    "govspeak" => ConfigurableContentBlocks::Govspeak,
    "default_date" => ConfigurableContentBlocks::DefaultDate,
    "default_select" => ConfigurableContentBlocks::DefaultSelect,
    "lead_image_select" => ConfigurableContentBlocks::LeadImageSelect,
    "default_object" => ConfigurableContentBlocks::DefaultObject,
    "default_array" => ConfigurableContentBlocks::DefaultArray,
    "ordered_select_with_search_tagging" => ConfigurableContentBlocks::OrderedSelectWithSearchTagging,
    "select_with_search_tagging" => ConfigurableContentBlocks::SelectWithSearchTagging,
  }.freeze

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

  def self.find_by_base_path_prefix(prefix)
    all.filter { |t| t.settings["base_path_prefix"] == prefix }
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
    @forms = type["forms"] || {}
    @presenters = type["presenters"] || {}
    @schema = type["schema"]
    @associations = type["associations"]
    @settings = type["settings"]
  end

  def label
    @title
  end

  def properties
    @schema["attributes"] || {}
  end

  def form(key = nil)
    return nil if @forms.empty?

    if key
      @forms[key]
    else
      # This 'else' is for the 'translations' page where all fields are displayed together
      # (No tabular interface)
      fields = @forms.reduce({}) do |acc, (_form_key, form_value)|
        acc.merge(form_value["fields"])
      end
      {
        "fields" => fields,
      }
    end
  end

  def presenter(key)
    @presenters[key]
  end

  class NotFoundError < StandardError
  end
end
