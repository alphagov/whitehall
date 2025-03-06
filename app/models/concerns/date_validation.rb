module DateValidation
  extend ActiveSupport::Concern

  included do
    attr_reader :invalid_date_attributes

    validates_with DateValidator

    after_validation :rationalise_date_errors

  private

    # In cases when a date attribute is invalid, it will be set to nil by pre_validate_date_attribute and will therefore
    # fail the presence validation. We therefore need to remove the presence error from each invalid date attribute to
    # avoid a confusing user experience where both the invalid date and presence errors show simultaneously
    def rationalise_date_errors
      @invalid_date_attributes&.each do |invalid_date_attribute|
        if errors.of_kind?(invalid_date_attribute, :blank)
          errors.delete(invalid_date_attribute, :blank)
        end
      end
    end
  end

  def pre_validate_date_attribute(attribute, date)
    @invalid_date_attributes = Set.new if @invalid_date_attributes.nil?
    if date.is_a?(Hash)
      begin
        # Rails will cast the year part of the date to 0 if the year input parameter is a non-numeric string
        # This only seems to happen to the year part, other parts remain as strings
        raise TypeError if date[1].zero?

        # Rails does not accept negative month values, but the Date constructor does
        raise TypeError if date[2].negative?

        Date.new(date[1], date[2], date[3])
        @invalid_date_attributes.delete(attribute)
      rescue ArgumentError, TypeError, NoMethodError
        @invalid_date_attributes.add(attribute)
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
      record.invalid_date_attributes&.each do |date_attribute|
        record.errors.add date_attribute, :invalid_date
      end
    end
  end
end
