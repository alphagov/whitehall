class ContentBlockManager::ContentBlockEdition::Details::Fields::OpeningHours::ItemComponent < ViewComponent::Base
  include ErrorsHelper

  DAYS = Date::DAYNAMES.rotate(1)
  HOURS = (1..12).to_a
  MINUTES = (0..59).map { |i| sprintf("%02d", i) }
  MERIDIAN = %w[AM PM].freeze

  def initialize(name_prefix:, id_prefix:, value:, index:, field:, errors:, can_be_deleted:)
    @name_prefix = name_prefix
    @id_prefix = id_prefix
    @value = value
    @index = index
    @field = field
    @errors = errors
    @can_be_deleted = can_be_deleted
  end

private

  attr_reader :name_prefix, :id_prefix, :value, :index, :field, :errors, :can_be_deleted

  def wrapper_classes
    [
      "app-c-content-block-manager-opening-hours-item-component",
      ("app-c-content-block-manager-opening-hours-item-component--immutable" unless can_be_deleted),
    ].join(" ")
  end

  def day_arguments(field_name)
    select_arguments(field_name).merge(
      options: options(field_name, DAYS),
      error_message: error_for_field_name(field_name),
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

  def time_error_message(prefix)
    content_tag(:p, error_for_field_name(prefix), class: "govuk-error-message") if show_time_errors?(prefix)
  end

  def time_error_class(prefix)
    "app-c-content-block-manager-opening-hours-item-component__time-group--error" if show_time_errors?(prefix)
  end

  def show_time_errors?(prefix)
    error_for_field_name(prefix).present?
  end

  def error_for_field_name(field_name)
    errors_for(errors, [error_prefix, index, field_name].compact.join("_").to_sym)&.first&.fetch(:text, nil)
  end

  def error_prefix
    id_prefix.gsub("content_block_manager_content_block_edition_", "")
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
