# Modified from https://gist.github.com/timocratic/5113293
require "addressable/uri"

# Accepts options[:message] and options[:allowed_protocols]
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
      record.errors.add(attribute, failure_message)
    elsif allowed_protocols.exclude?(uri.scheme)
      record.errors.add(attribute, "is not a valid URI. Make sure it starts with http(s)")
    end
  rescue URI::Error
    record.errors.add(attribute, failure_message)
  end

private

  def failure_message
    options[:message] || "is not a valid URI."
  end

  def allowed_protocols
    @allowed_protocols ||= [options[:allowed_protocols] || %w[http https]].flatten
  end
end
