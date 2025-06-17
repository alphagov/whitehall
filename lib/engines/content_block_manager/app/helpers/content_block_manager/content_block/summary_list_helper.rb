module ContentBlockManager::ContentBlock::SummaryListHelper
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

  def key_to_title(key)
    subject, count = key.split("/")
    if count
      "#{subject.singularize} #{count.to_i + 1}".titleize
    else
      subject.titleize
    end
  end
end
