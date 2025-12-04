class DurationValidator < ActiveModel::Validator
  def validate(record)
    start_attr = options[:start]
    end_attr = options[:end]

    raise ArgumentError, "Start Attribute and End Attribute options are required" unless start_attr && end_attr

    start_value = record.send(start_attr.to_sym)
    end_value = record.send(end_attr.to_sym)

    if start_value.nil? && end_value.present?
      record.errors.add(start_attr.to_sym, "must be provided if #{end_attr.humanize} is present")
      return
    end

    if start_value && end_value
      duration = ActiveSupport::Duration.parse(options[:within])
      duration_range = (start_value..(start_value + duration))

      if duration_range.exclude?(end_value)
        record.errors.add(end_attr.to_sym, "must be between #{duration_range.begin} and #{duration_range.end}")
      end
    end
  end
end
