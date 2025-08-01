# Accepts options[:message] and options[:allowed_protocols]
class GovUkUrlFormatValidator < ActiveModel::EachValidator
  EXTERNAL_HOST_ALLOW_LIST = %w[
    .caa.co.uk
    .gov.uk
    .independent-inquiry.uk
    .judiciary.uk
    .nationalhighways.co.uk
    .nhs.uk
    .police.uk
    .pubscodeadjudicator.org.uk
    .ukri.org
  ].freeze

  def validate_each(record, attribute, value)
    unless self.class.matches_gov_uk?(value) || matches_allow_list?(value)
      record.errors.add(attribute)
    end
  end

  def self.matches_gov_uk?(value)
    %r{\A#{Whitehall.public_protocol}://#{Whitehall.public_host}/}.match?(value)
  end

private

  # Expects a fully qualified URL, but anything else might be OK (e.g. for internal links).
  # We don't need to report bad URLs here as whatever model is using the GovUkUrlFormatValidator
  # should also be using the UriValidator.
  def matches_allow_list?(value)
    uri = URI.parse(value)
    return true unless uri.host

    uri.host.end_with?(*EXTERNAL_HOST_ALLOW_LIST)
  rescue URI::InvalidURIError
    true
  end
end
