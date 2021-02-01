# Accepts options[:message] and options[:allowed_protocols]
class GovUkUrlFormatValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless matches_gov_uk?(value) || matches_judiciary_uk?(value)
      record.errors[attribute] << failure_message
    end
  end

private

  def failure_message
    options[:message] || "must be in the form of #{Whitehall.public_protocol}://#{Whitehall.public_host}/example"
  end

  def matches_gov_uk?(value)
    %r{\A#{Whitehall.public_protocol}://#{Whitehall.public_host}/}.match?(value)
  end

  def matches_judiciary_uk?(value)
    uri = URI.parse(value)
    uri.host&.end_with?(".judiciary.uk")
  rescue URI::InvalidURIError
    false
  end
end
