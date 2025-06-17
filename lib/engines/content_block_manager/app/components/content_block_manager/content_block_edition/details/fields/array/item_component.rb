class ContentBlockManager::ContentBlockEdition::Details::Fields::Array::ItemComponent < ViewComponent::Base
  def initialize(field_name:, array_items:, name_prefix:, id_prefix:, value:, index:)
    @field_name = field_name
    @array_items = array_items
    @name_prefix = name_prefix
    @id_prefix = id_prefix
    @value = value
    @index = index
  end

private

  attr_reader :field_name, :array_items, :name_prefix, :id_prefix, :value, :index

  def name
    "#{name_prefix}[]"
  end

  def id
    "#{id_prefix}_#{index}"
  end

  def field_value
    value[index]
  end

  def object_field_name(field)
    "#{name}[#{field}]"
  end

  def object_field_id(field)
    "#{id}_#{field}"
  end

  def object_field_value(field)
    value ? field_value&.fetch(field) : nil
  end

  def select_options(enum, value)
    enum.map do |item|
      {
        text: item.humanize,
        value: item,
        selected: item == value,
      }
    end
  end
end
