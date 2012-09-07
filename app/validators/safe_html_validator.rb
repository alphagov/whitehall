class SafeHtmlValidator < ActiveModel::Validator
  def validate(record)
    record.changes.each do |field_name, (old_value, new_value)|
      check_struct(record, field_name, new_value)
    end
  end

  def check_struct(record, field_name, value)
    if value.respond_to?(:values) # e.g. Hash
      value.values.each { |entry| check_struct(record, field_name, entry) }
    elsif value.respond_to?(:each) # e.g. Array
      value.each { |entry| check_struct(record, field_name, entry) }
    elsif value.is_a?(String)
      check_string(record, field_name, value)
    end
  end

  def check_string(record, field_name, string)
    unless Govspeak::HtmlValidator.new(string).valid?
      error = "cannot include invalid formatting or JavaScript"
      record.errors.add(field_name, error)
    end
  end
end
