# Modified from https://gist.github.com/timocratic/5113293
require "addressable/uri"

class UriValidator < ActiveModel::EachValidator
  MAX_LENGTH = 255

  def validate_each(record, attribute, value)
    return if value.nil?

    if value.length > MAX_LENGTH
      record.errors.add(attribute, "is too long. Please shorten the URL to less than #{MAX_LENGTH} characters.")
      return
    end

    uri = URI.parse(value)

    if uri.blank?
      record.errors.add(attribute, "is not valid.")
    elsif %w[http https].exclude?(uri.scheme)
      record.errors.add(attribute, "is not valid. Make sure it starts with http(s)")
    end
  rescue URI::Error
    record.errors.add(attribute, "is not valid.")
  end
end
