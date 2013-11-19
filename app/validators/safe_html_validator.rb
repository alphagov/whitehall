class SafeHtmlValidator < ActiveModel::Validator
  def validate(record)
    return if Whitehall.skip_safe_html_validation || record.marked_for_destruction?
    record.changes.each do |field_name, (old_value, new_value)|
      check_struct(record, field_name, new_value)
    end
  end

private

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
    record.errors.add(field_name, "cannot include invalid formatting or JavaScript") if unacceptable_govspeak?(string)
  end

  def self.cache
    @cache ||= ActiveSupport::Cache::MemoryStore.new
  end

  def unacceptable_govspeak?(string)
    self.class.cache.fetch(string) do
      !Govspeak::HtmlValidator.new(string).valid?
    end
  end
end
