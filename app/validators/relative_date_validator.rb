class RelativeDateValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.nil?

    if options[:before].present? && options[:before].call <= value
      record.errors.add(attribute, :date_before, message: options[:before_message] || "must be before #{options[:before].call}")
    end
    if options[:after].present? && options[:after].call >= value
      record.errors.add(attribute, :date_after, message: options[:after_message] || "must be after #{options[:after].call}")
    end
  end
end
