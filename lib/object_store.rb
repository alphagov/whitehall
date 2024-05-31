module ObjectStore
  class UnknownItemType < StandardError
    def initialize(item_type)
      super("Unknown item type: #{item_type}")
    end
  end

  class ItemType
    attr_accessor :name, :fields

    def field_names
      fields.map(&:name)
    end
  end

  class Field
    attr_accessor :name, :type, :required

    def required?
      required == true
    end
  end

  def self.configuration
    @configuration ||= OpenStruct.new
  end

  def self.configure
    yield(configuration)
  end

  def self.items
    @items ||= configuration["fields"].map do |name, config|
      properties = config["properties"] || []
      item_type = ItemType.new
      item_type.name = name
      item_type.fields = properties.map do |field_name, _v|
        field = Field.new
        field.name = field_name
        field.type = properties.dig(field_name, "type")
        field.required = config["required"]&.include?(field_name)
        field
      end
      item_type
    end
  end

  def self.item_type_by_name(item_type)
    items.find { |i| i.name == item_type } || raise(UnknownItemType, item_type)
  end

  def self.item_types
    items.map(&:name)
  end
end
