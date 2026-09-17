class NationApplicabilityValidator < ActiveModel::Validator
  ALL_NATIONS = "all".freeze
  VALID_VALUES = %w[all england scotland wales northern_ireland].freeze

  def initialize(opts = {})
    @attributes = opts[:attributes]
    super
  end

  def validate(record)
    @attributes.each do |attribute_name|
      value = record.send(attribute_name)
      selected = Array(value&.dig("selected"))

      if selected.empty?
        record.errors.add(
          attribute_name.to_sym,
          :blank,
          message: "- you must select whether this content applies to all UK nations or which nations it does not apply to",
        )
      elsif (selected - VALID_VALUES).any?
        record.errors.add(attribute_name.to_sym, :invalid, message: "- contains an invalid nation")
      elsif selected.include?(ALL_NATIONS) && selected.size > 1
        record.errors.add(attribute_name.to_sym, :invalid, message: "- you cannot select all UK nations and also exclude nations")
      else
        validate_alternative_urls(record, attribute_name, selected, value["alternative_urls"])
      end
    end
  end

private

  def validate_alternative_urls(record, attribute_name, selected, alternative_urls)
    (selected - [ALL_NATIONS]).each do |nation_key|
      url = alternative_urls&.dig(nation_key)
      next if url.blank?

      attribute = :"#{attribute_name}.alternative_urls.#{nation_key}"
      UriValidator.new(attributes: [attribute]).validate_each(record, attribute, url)
    end
  end
end
