class NationApplicabilityValidator < ActiveModel::Validator
  ALL_NATIONS = "all".freeze
  VALID_VALUES = %w[all england scotland wales northern_ireland].freeze

  def initialize(opts = {})
    @attributes = opts[:attributes]
    super
  end

  def validate(record)
    @attributes.each do |attribute_name|
      entries = ConfigurableContentBlocks::NationApplicability.cast(record.send(attribute_name))
      nations = entries.map { |entry| entry["nation"] }

      if nations.empty?
        record.errors.add(
          attribute_name.to_sym,
          :blank,
          message: "- you must select whether this content applies to all UK nations or which nations it does not apply to",
        )
      elsif (nations - VALID_VALUES).any?
        record.errors.add(attribute_name.to_sym, :invalid, message: "- contains an invalid nation")
      elsif nations.include?(ALL_NATIONS) && nations.size > 1
        record.errors.add(attribute_name.to_sym, :invalid, message: "- you cannot select all UK nations and also exclude nations")
      else
        validate_alternative_urls(record, attribute_name, entries)
      end
    end
  end

private

  def validate_alternative_urls(record, attribute_name, entries)
    entries.each do |entry|
      next if entry["nation"] == ALL_NATIONS

      url = entry["alternative_url"]
      next if url.blank?

      attribute = :"#{attribute_name}.alternative_urls.#{entry['nation']}"
      UriValidator.new(attributes: [attribute]).validate_each(record, attribute, url)
    end
  end
end
