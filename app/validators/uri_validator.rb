# Modified from https://gist.github.com/timocratic/5113293
require 'addressable/uri'

#Accepts options[:message] and options[:allowed_protocols]
class UriValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if !(uri = Addressable::URI.parse(value))
      record.errors[attribute] << failure_message
    elsif !allowed_protocols.include?(uri.scheme)
      record.errors[attribute] << "is not valid. Make sure it starts with http(s)"
    end
  rescue Addressable::URI::InvalidURIError
    record.errors[attribute] << failure_message
  end

private

  def failure_message
    options[:message] || "is not valid."
  end

  def allowed_protocols
    @allowed_protocols ||= [(options[:allowed_protocols] || %w[http https])].flatten
  end
end
