# Modified from https://gist.github.com/timocratic/5113293
require 'addressable/uri'

#Accepts options[:message] and options[:allowed_protocols]
class UriValidator < ActiveModel::EachValidator

  def validate_each(record, attribute, value)
    uri = parse_uri(value)
    if !uri
      record.errors[attribute] << failure_message
    elsif !allowed_protocols.include?(uri.scheme)
      record.errors[attribute] << "is not valid. Make sure it starts with http(s)"
    end
  end

private

  def failure_message
    options[:message] || "is not valid."
  end

  def allowed_protocols
    @allowed_protocols ||= [(options[:allowed_protocols] || ['http', 'https'])].flatten
  end

  def parse_uri(value)
    Addressable::URI.parse(value)
  rescue Addressable::URI::InvalidURIError
  end

end