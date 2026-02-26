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

  def field_at(path, fields = nil)
    fields = form["fields"] if fields.nil?
    fields.each do |_key, field|
      matchable_path = path[..(field["attribute_path"].size)]
      if (field["attribute_path"] == matchable_path.to_a) || field["attribute_path"].empty?
        if field["fields"]
          return field_at(matchable_path, field["fields"])
        elsif field["attribute_path"] == path.to_a
          return field
        end
      end
    end
    nil
  end

  def error_labels
    {}.tap do |labels|
      visitor = lambda do |path, field|
        # we only want labels for leaf fields, so do nothing if this field isn't one
        return if field["fields"]

        labels[path.validation_error_attribute] = field["title"]
      end

      visit_fields_with(visitor)
    end
  end

  def field_paths(&block)
    [].tap do |fields|
      visitor = lambda do |path, field|
        # we only want labels for leaf fields, so do nothing if this field isn't one
        return if field["fields"]

        fields << path if !block_given? || block.call(field)
      end

      visit_fields_with(visitor)
    end
  end

  def required_field_paths
    field_paths { |field| field["required"] == true }
  end

  def presenter(key)
    @presenters[key]
  end

  class NotFoundError < StandardError
  end

private

  def visit_fields_with(visitor)
    walk_fields { |path, field| visitor.call(path, field) }
  end

  def walk_fields(fields = nil, path = ConfigurableContentBlocks::Path.new, &block)
    fields ||= form["fields"]

    fields.each do |_key, field|
      current_path = path.push(field["attribute_path"])
      yield(current_path, field)
      if field["fields"]
        walk_fields(field["fields"], current_path, &block)
      end
    end
  end
end
