# frozen_string_literal: true

class Admin::DatetimeComponent < ViewComponent::Base
  include ErrorsHelper

  attr_reader :object, :field_name, :default_date, :start_year, :end_year

  def initialize(object:, field_name:, prefix: nil, default_date: nil, start_year: nil, end_year: nil)
    @object = object
    @field_name = field_name
    @prefix = prefix
    @default_date = default_date
    @start_year = start_year
    @end_year = end_year
  end

private

  def year_value
    object.public_send(field_name)&.year || default_year
  end

  def month_value
    object.public_send(field_name)&.month || default_month
  end

  def day_value
    object.public_send(field_name)&.day || default_day
  end

  def hour_value
    object.public_send(field_name)&.hour || default_hour
  end

  def minute_value
    object.public_send(field_name)&.min || default_minute
  end

  def default_year
    default_date&.year
  end

  def default_month
    default_date&.month
  end

  def default_day
    default_date&.day
  end

  def default_hour
    default_date&.hour
  end

  def default_minute
    default_date&.min
  end

  def prefix
    @prefix ||= @prefix || object.class.to_s.underscore
  end
end
