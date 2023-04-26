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
        text: error.full_message,
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
end
