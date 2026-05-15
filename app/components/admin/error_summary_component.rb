# frozen_string_literal: true

class Admin::ErrorSummaryComponent < ViewComponent::Base
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
    sorted_errors.map do |error|
      message = if dotted_array_attribute?(error)
                  format_dotted_attribute_message(error)
                elsif object.respond_to?(:error_labels) && object.error_labels.key?(error.attribute.to_s)
                  "#{object.error_labels[error.attribute.to_s]} #{error.message}"
                else
                  error.full_message
                end

      error_item = {
        text: message,
        data_attributes: {
          module: "ga4-auto-tracker",
          "ga4-auto": {
            event_name: "form_error",
            type: ga4_title,
            text: message.to_s.humanize,
            section: error.attribute.to_s.humanize,
            action: "error",
          }.to_json,
        },
      }

      error_item[:href] = "##{parent_class}_#{error.attribute.to_s.gsub('.', '_')}" unless error.attribute == :base
      error_item
    end
  end

  def sorted_errors
    return errors unless object.respond_to?(:error_field_order)

    field_order = object.error_field_order
    errors.sort_by do |error|
      field_order.index(error.attribute.to_s) || field_order.length
    end
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

  def ga4_title
    return object.class.name.humanize if [ActiveModel::Errors, Array].include?(object.class)

    "#{object.try(:new_record?) ? 'New' : 'Editing'} #{object.model_name.human.downcase.titleize}"
  end

  def dotted_array_attribute?(error)
    error.attribute.to_s.split(".").any? { |part| part.match?(/\A\d+\z/) }
  end

  def format_dotted_attribute_message(error)
    attribute_label = error.attribute.to_s.split(".").map { |part|
      part.match?(/\A\d+\z/) ? (part.to_i + 1).to_s : part.humanize.downcase
    }.join(" ").capitalize
    "#{attribute_label} #{error.message}"
  end
end
