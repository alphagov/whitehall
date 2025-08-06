# Modified from https://gist.github.com/timocratic/5113293
require "addressable/uri"

# Accepts options[:message] and options[:allowed_protocols]
class UriValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.nil?

    uri = URI.parse(value)

    if uri.blank?
      record.errors.add(attribute, failure_message)
    elsif allowed_protocols.exclude?(uri.scheme)
      record.errors.add(attribute, "is not valid. Make sure it starts with http(s)")
    end
  rescue URI::Error
    record.errors.add(attribute, failure_message)
  end

private

  def failure_message
    options[:message] || "is not valid."
  end

  def allowed_protocols
    @allowed_protocols ||= [options[:allowed_protocols] || %w[http https]].flatten
  end
end
