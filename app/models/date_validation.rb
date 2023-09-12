module DateValidation
  extend ActiveSupport::Concern

  attr_reader :invalid_date_attributes

  included do
    validates_with DateValidator

    after_validation :rationalise_date_errors

  private

    # In cases when a date attribute is invalid, it will be set to nil by pre_validate_date_attribute and will therefore
    # fail the presence validation. We therefore need to remove the presence error from each invalid date attribute to
    # avoid a confusing user experience where both the invalid date and presence errors show simultaneously
    def rationalise_date_errors
      return if invalid_date_attributes.nil?

      invalid_date_attributes.each do |invalid_date_attribute|
        if errors.of_kind?(invalid_date_attribute, :blank)
          errors.delete(invalid_date_attribute, :blank)
        end
      end
    end
  end

  def pre_validate_date_attribute(attribute, date)
    if date.is_a?(Hash)
      begin
        Date.new(date[1], date[2], date[3])
      rescue ArgumentError, TypeError
        @invalid_date_attributes = [] if @invalid_date_attributes.nil?
        @invalid_date_attributes << attribute
        date = nil
      end
    end
    date
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
        record.errors.add date_attribute, :invalid_date, message: "must be a valid date in the correct format"
      end
    end
  end
end
