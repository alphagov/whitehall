class UrlValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless value =~ /\Ahttps?\:\/\//
      record.errors[attribute] << "must start with http(s)"
    end
  end
end
