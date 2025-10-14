class SafeHtmlValidator < ActiveModel::Validator
  cattr_reader(:cache) { ActiveSupport::Cache::MemoryStore.new }

  def initialize(opts = {})
    @attributes = (opts[:attributes] || [opts[:attribute]]).compact.map(&:to_s)
    super
  end

  def validate(record)
    @record = record

    return if Whitehall.skip_safe_html_validation || @record.marked_for_destruction?

    @record.changes
      .select { |attribute| @attributes.empty? || @attributes.include?(attribute) }
      .each do |attribute_name, (_old_value, new_value)|
        check_attribute_for_safety(attribute_name, new_value)
      end
  end

private

  def check_attribute_for_safety(attribute_name, value)
    if value.respond_to?(:each_value) # e.g. Hash
      value.each_value { |entry| check_attribute_for_safety(attribute_name, entry) }
    elsif value.respond_to?(:each) # e.g. Array
      value.each { |entry| check_attribute_for_safety(attribute_name, entry) }
    elsif value.is_a?(String)
      check_string_is_safe(attribute_name, value)
    end
  end

  def check_string_is_safe(attribute_name, string)
    @record.errors.add(attribute_name, "cannot include invalid formatting or JavaScript") unless valid_govspeak?(string)
  end

  def valid_govspeak?(string)
    return true if string.blank?

    self.class.cache.fetch(string) do
      Govspeak::HtmlValidator.new(string).valid?
    end
  end
end
