# Accepts options[:message] and options[:allowed_protocols]
class GovUkUrlFormatValidator < ActiveModel::EachValidator
  EXTERNAL_HOST_ALLOW_LIST = %w[.gov.uk .judiciary.uk .nhs.uk .ukri.org .nationalhighways.co.uk .protectuk.police.uk].freeze

  def validate_each(record, attribute, value)
    unless self.class.matches_gov_uk?(value) || matches_allow_list?(value)
      record.errors.add(attribute, message: failure_message)
    end
  end

  def self.matches_gov_uk?(value)
    %r{\A#{Whitehall.public_protocol}://#{Whitehall.public_host}/}.match?(value)
  end

private

  def failure_message
    options[:message] || "must be in the form of #{Whitehall.public_protocol}://#{Whitehall.public_host}/example"
  end

  def matches_allow_list?(value)
    uri = URI.parse(value)
    uri.host&.end_with?(*EXTERNAL_HOST_ALLOW_LIST)
  rescue URI::InvalidURIError
    false
  end
end
