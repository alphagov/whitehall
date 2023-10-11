# frozen_string_literal: true

class Admin::ErrorSummaryComponent < ViewComponent::Base
  include Admin::AnalyticsHelper

  attr_reader :object

  def initialize(object:, parent_class: nil)
    @object = object
    @parent_class = parent_class
  end

  def render?
    errors.present?
  end

private

  def title
    "There is a problem"
  end

  def humanized_class_name
    @humanized_class_name ||= object.try(:format_name) || object.class.name.demodulize.underscore.humanize.downcase
  end

  def error_items
    errors.map do |error|
      error_item = {
        text: error_message_text(error),
        data_attributes: track_analytics_data("form-error", analytics_action, error.full_message),
      }

      error_item[:href] = "##{parent_class}_#{error.attribute.to_s.gsub('.', '_')}" unless error.attribute == :base
      error_item
    end
  end

  def analytics_action
    @analytics_action ||= "#{humanized_class_name}-error"
  end

  def parent_class
    @parent_class ||= object.class.to_s.underscore
  end

  def errors
    @errors ||= if [ActiveModel::Errors, Array].include?(object.class)
                  object
                else
                  object.errors
                end
  end

  def error_message_text(error)
    if custom_error_present_in_locales?(error)
      custom_error_message(error)
    else
      error.full_message
    end
  end

  def custom_error_present_in_locales?(error)
    custom_error_message(error)
  rescue RuntimeError
    false
  end

  def custom_error_message(error)
    I18n.t("activerecord.errors.models.#{model_for_locale(error)}.attributes.#{attribute_for_locale(error)}.#{error.type}")
  end

  def model_for_locale(error)
    return parent_class unless error.is_a?(ActiveModel::NestedError)

    error.attribute.to_s.split(".")[-2]
  end

  def attribute_for_locale(error)
    return error.attribute unless error.is_a?(ActiveModel::NestedError)

    error.attribute.to_s.split(".").last
  end
end
