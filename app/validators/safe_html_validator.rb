class SafeHtmlValidator < ActiveModel::Validator
  cattr_reader(:cache) { ActiveSupport::Cache::MemoryStore.new }

  def initialize(opts = {})
    # normalise once to symbols so we don't care if record uses string/symbol keys
    @attributes = (opts[:attributes] || [opts[:attribute]]).compact.map!(&:to_sym)
    super
  end

  def validate(record)
    @record = record

    return if Whitehall.skip_safe_html_validation || @record.marked_for_destruction?

    @record.changes.each do |attribute_name, (_old_value, new_value)|
      # filter using symbolised key, but pass the original name to errors.add
      next if @attributes.any? && !@attributes.include?(attribute_name.to_sym)

      check_attribute_for_safety(attribute_name, new_value)
    end
  end

private

  def check_attribute_for_safety(attribute_name, value)
    if value.respond_to?(:each_value) # e.g. Hash
      value.each_value { |entry| check_attribute_for_safety(attribute_name, entry) }
    elsif value.respond_to?(:each) && !value.is_a?(String) # Array/Enumerable
      value.each { |entry| check_attribute_for_safety(attribute_name, entry) }
    elsif value.is_a?(String)
      check_string_is_safe(attribute_name, value)
    end
  end

  def check_string_is_safe(attribute_name, string)
    @record.errors.add(attribute_name, :unsafe_html, message: "cannot include invalid formatting or JavaScript") unless valid_govspeak?(string)
  end

  def valid_govspeak?(string)
    return true if string.blank?

    self.class.cache.fetch(string) do
      Govspeak::HtmlValidator.new(string).valid?
    end
  end
end
