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

      if value.nil?
        record.errors.add(
          attribute_name.to_sym,
          :blank,
          message: "- you must select whether this content applies to all UK nations or which nations it does not apply to",
        )
      elsif (value - VALID_VALUES).any?
        record.errors.add(attribute_name.to_sym, :invalid, message: "- contains an invalid nation")
      elsif value.include?(ALL_NATIONS) && value.size > 1
        record.errors.add(attribute_name.to_sym, :invalid, message: "- you cannot select all UK nations and also exclude nations")
      end
    end
  end
end
