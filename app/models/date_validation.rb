module DateValidation
  extend ActiveSupport::Concern

  attr_reader :invalid_date_attributes

  included do
    validates_with DateValidator

    # @param attribute Symbol
    # @param date Hash|Date|DateTime|String|nil
    # @return Hash|Date|DateTime|String|nil
    def pre_validate_date_attribute(attribute, date)
      if date.is_a?(Hash)
        begin
          raise ArgumentError if date.values.any?(&:nil?)
          raise ArgumentError if date[1].to_i.zero? || date[2].to_i.zero? || date[3].to_i.zero?

          Date.new(date[1], date[2], date[3])
        rescue ArgumentError
          @invalid_date_attributes = [] if @invalid_date_attributes.nil?
          @invalid_date_attributes << attribute
          date = nil
        end
      end
      date
    end
  end

  class_methods do
    def date_attributes(*attributes)
      attributes.each do |attribute|
        define_method("#{attribute}=") do |value|
          super(pre_validate_date_attribute(attribute, value))
        end
      end
    end
  end

  class DateValidator < ActiveModel::Validator
    def validate(record)
      return if record.invalid_date_attributes.nil?

      record.invalid_date_attributes.each do |date_attribute|
        record.errors.add date_attribute, "must be a valid date in the correct format"
      end
    end
  end
end
