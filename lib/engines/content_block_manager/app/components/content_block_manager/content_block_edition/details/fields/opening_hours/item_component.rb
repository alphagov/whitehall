class ContentBlockManager::ContentBlockEdition::Details::Fields::OpeningHours::ItemComponent < ViewComponent::Base
  DAYS = Date::DAYNAMES.rotate(1)
  HOURS = (1..12).to_a
  MINUTES = (0..59).map { |i| sprintf("%02d", i) }
  MERIDIAN = %w[AM PM].freeze

  def initialize(name_prefix:, id_prefix:, value:, index:, field:)
    @name_prefix = name_prefix
    @id_prefix = id_prefix
    @value = value
    @index = index
    @field = field
  end

private

  attr_reader :name_prefix, :id_prefix, :value, :index, :field

  def day_arguments(field_name)
    select_arguments(field_name).merge(
      options: options(field_name, DAYS)
    )
  end

  def hour_arguments(field_name)
    select_arguments(field_name).merge(
      options: options(field_name, HOURS),
    )
  end

  def minute_arguments(field_name)
    select_arguments(field_name).merge(
      options: options(field_name, MINUTES),
    )
  end

  def meridian_arguments(field_name)
    select_arguments(field_name).merge(
      options: options(field_name, %w[AM PM]),
    )
  end

  def select_arguments(field_name)
    {
      label: I18n.t("content_block_edition.details.labels.contacts.telephones.opening_hours.#{field_name}"),
      name: "#{name_prefix}[][#{field_name}]",
      id: "#{id_prefix}_#{index}_#{field_name.parameterize.underscore}",
    }
  end

  def options(field_name, items)
    options = [{
      text: "Select",
      value: "",
      selected: value_for_field(field_name).nil?,
    }]

    items.each do |item|
      options << {
        text: item,
        value: item,
        selected: value_for_field(field_name) == item.to_s,
      }
    end

    options
  end

  def value_for_field(field_name)
    return nil if value.blank?

    if field_name =~ /([a-z_]+)\((h|m|meridian)\)/
      time = value_for_field(::Regexp.last_match(1)) || ""
      value_for_time_field(time, ::Regexp.last_match(2))
    else
      field_value&.fetch(field_name, nil)
    end
  end

  def value_for_time_field(time, part)
    case part
    when "h"
      time.split(":").first
    when "m"
      time.split(":").last.try { |val| val[0..1] }
    else
      time[-2..]
    end
  end

  def field_value
    value[index]
  end
end
