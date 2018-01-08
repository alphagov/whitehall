class SafeHtmlValidator < ActiveModel::Validator
  def validate(record)
    @record = record

    return if Whitehall.skip_safe_html_validation || @record.marked_for_destruction?

    @record.changes.each do |attribute_name, (_old_value, new_value)|
      check_attribute_for_safety(attribute_name, new_value)
    end
  end

private

  def check_attribute_for_safety(attribute_name, value)
    if value.respond_to?(:values) # e.g. Hash
      value.values.each { |entry| check_attribute_for_safety(attribute_name, entry) }
    elsif value.respond_to?(:each) # e.g. Array
      value.each { |entry| check_attribute_for_safety(attribute_name, entry) }
    elsif value.is_a?(String)
      check_string_is_safe(attribute_name, value)
    end
  end

  def check_string_is_safe(attribute_name, string)
    @record.errors.add(attribute_name, "cannot include invalid formatting or JavaScript") if unacceptable_govspeak?(string)
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
