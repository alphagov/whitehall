class RecentDateValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if (@allow_nil && value.nil?) || (@allow_blank && value.blank?)
    record.errors.add(attribute, "must be present") && return if value.blank?
    record.errors.add(attribute, "invalid type") && return if !value.respond_to?(:to_date)
    unless value.to_date > Date.parse('1900-01-01')
      record.errors.add(attribute, "should be greater than 1900")
    end
  end
end
