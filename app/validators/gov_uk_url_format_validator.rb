# Accepts options[:message] and options[:allowed_protocols]
class GovUkUrlFormatValidator < ActiveModel::EachValidator
  EXTERNAL_HOST_ALLOW_LIST = %w[
    .caa.co.uk
    .gov.uk
    .independent-inquiry.uk
    .internationalaisafetyreport.org
    .judiciary.uk
    .nationalhighways.co.uk
    .nhs.uk
    .police.uk
    .pubscodeadjudicator.org.uk
    .ukri.org
  ].freeze

  def validate_each(record, attribute, value)
    unless self.class.matches_gov_uk?(value) || matches_allow_list?(value)
      record.errors.add(attribute, "is not a GOV.UK URL")
    end
  end

  def self.matches_gov_uk?(value)
    uri = URI.parse(value)
    return false unless uri.is_a?(URI::HTTP) || uri.is_a?(URI::HTTPS)

    host = uri.host&.downcase
    return false if host.blank?

    %w[
      gov.uk
      www.gov.uk
      staging.publishing.service.gov.uk
      www.staging.publishing.service.gov.uk
      integration.publishing.service.gov.uk
      www.integration.publishing.service.gov.uk
      test.gov.uk
      www.test.gov.uk
      dev.gov.uk
      www.dev.gov.uk
    ].include?(host)
  rescue URI::InvalidURIError
    false
  end

private

  def matches_allow_list?(value)
    uri = URI.parse(value)
    uri.host&.end_with?(*EXTERNAL_HOST_ALLOW_LIST) ||
      EXTERNAL_HOST_ALLOW_LIST.any? { |domain| uri.host == domain.delete_prefix(".") }
  rescue URI::InvalidURIError
    false
  end
end
