module ContentBlockManager::ContentBlock::SummaryListHelper
  include ContentBlockManager::ContentBlock::TranslationHelper

  def fields_for_schema(schema)
    schema.hide_title? ? schema.fields.reject { |field| field.name == "title" } : schema.fields
  end

  def first_class_items(input)
    result = {}

    input.each do |key, value|
      case value
      when String
        result[key] = value
      when Array
        value.each_with_index do |item, index|
          result["#{key}/#{index}"] = item if item.is_a?(String)
        end
      end
    end

    result
  end

  def nested_items(input)
    input.select do |_key, value|
      value.is_a?(Hash) || value.is_a?(Array) && value.all? { |item| item.is_a?(Hash) }
    end
  end

  def key_to_title(key, object_type = nil)
    subject, count = key.split("/")
    if count
      humanized_label("#{subject.singularize} #{count.to_i + 1}", object_type)
    else
      humanized_label(subject, object_type)
    end
  end
end
