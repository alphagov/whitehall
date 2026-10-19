class NationApplicabilityValidator < ActiveModel::Validator
  include Presenters::PublishingApi::NationApplicabilityHelper

  ALL_NATIONS = "all".freeze
  VALID_VALUES = %w[all england scotland wales northern_ireland].freeze

  def initialize(opts = {})
    @attributes = opts[:attributes]
    super
  end

  def validate(record)
    @attributes.each do |attribute_name|
      entries = cast_nation_applicability(record.send(attribute_name))
      nations = entries.map { |entry| entry["nation"] }

      if nations.empty?
        record.errors.add(
          attribute_name.to_sym,
          :blank,
          message: "- you must select whether this content applies to all UK nations or which nations it does not apply to",
        )
      elsif (nations - VALID_VALUES).any?
        record.errors.add(attribute_name.to_sym, :invalid_nation, message: "- contains an invalid nation")
      elsif nations.include?(ALL_NATIONS) && nations.size > 1
        record.errors.add(attribute_name.to_sym, :incompatible_options, message: "- you cannot select all UK nations and also exclude nations")
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

      attribute = :"#{attribute_name}.#{entry['nation']}.alternative_url"
      UriValidator.new(attributes: [attribute]).validate_each(record, attribute, url)
    end
  end
end
