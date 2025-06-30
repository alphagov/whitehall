class ContentBlockManager::ContentBlockEdition::Details::Fields::Array::ItemComponent < ViewComponent::Base
  include ErrorsHelper

  def initialize(field_name:, array_items:, name_prefix:, id_prefix:, value:, index:, errors:, error_lookup_prefix:)
    @field_name = field_name
    @array_items = array_items
    @name_prefix = name_prefix
    @id_prefix = id_prefix
    @value = value
    @index = index
    @errors = errors
    @error_lookup_prefix = error_lookup_prefix
  end

private

  attr_reader :field_name, :array_items, :name_prefix, :id_prefix, :value, :index, :errors, :error_lookup_prefix

  def name
    "#{name_prefix}[]"
  end

  def id
    "#{id_prefix}_#{index}"
  end

  def field_value
    value[index]
  end

  def error_items(field = nil)
    errors_for(errors, [error_lookup_prefix, index, field].compact.join("_").to_sym)
  end

  def select_error_message(field = nil)
    error_items(field)&.first&.fetch(:text)
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
    options = [{
      text: "Select",
      value: "",
      selected: value.nil?,
    }]

    enum.each do |item|
      options << {
        text: item.humanize,
        value: item,
        selected: item == value,
      }
    end

    options
  end
end
