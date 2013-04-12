class UrlValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless value =~ URI::regexp && value =~ /\Ahttps?\:\/\//
      record.errors[attribute] << 'is not a valid. Make sure it starts with http(s)'
    end
  end
end
