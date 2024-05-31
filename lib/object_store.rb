module ObjectStore
  class UnknownItemType < StandardError
    def initialize(item_type)
      super("Unknown item type: #{item_type}")
    end
  end

  def self.configuration
    @configuration ||= OpenStruct.new
  end

  def self.configure
    yield(configuration)
  end

  def self.config_for_item_type(item_type)
    configuration.fields[item_type] || raise(UnknownItemType, item_type)
  end

  def self.fields_for_item_type(item_type)
    config_for_item_type(item_type)&.fetch("properties", nil)
  end

  def self.field_is_required?(item_type, field_name)
    required_fields_for_item_type(item_type).include?(field_name)
  end

  def self.required_fields_for_item_type(item_type)
    config_for_item_type(item_type)&.fetch("required", nil)
  end

  def self.field_names_for_item_type(item_type)
    fields_for_item_type(item_type).keys
  end

  def self.item_types
    configuration.fields.keys
  end
end
