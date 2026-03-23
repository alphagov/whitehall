# Accepts options[:message] and options[:allowed_protocols]
class GovUkUrlFormatValidator < ActiveModel::EachValidator
  EXTERNAL_HOST_ALLOW_LIST = %w[
    .caa.co.uk
    .independent-inquiry.uk
    .internationalaisafetyreport.org
    .judiciary.uk
    .nationalhighways.co.uk
    .nhs.uk
    .police.uk
    .pubscodeadjudicator.org.uk
    .ukri.org
  ].freeze

  GOV_UK_CANONICAL_HOSTS = %w[
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
  ].freeze

  GOV_UK_ASSETS_HOSTS = %w[
    assets.publishing.service.gov.uk
    assets.staging.publishing.service.gov.uk
    assets.integration.publishing.service.gov.uk
  ].freeze

  def validate_each(record, attribute, value)
    host = self.class.host_for(value)
    return if host.blank?

    unless self.class.allowed?(host)
      record.errors.add(attribute, options[:message] || "is not a GOV.UK URL")
    end
  end

  def self.can_be_converted_to_relative_path?(value)
    host = host_for(value)
    host.present? && proper_gov_uk_host?(host)
  end

  def self.host_for(value)
    uri = URI.parse(value.to_s)
    return nil unless uri.is_a?(URI::HTTP) || uri.is_a?(URI::HTTPS)

    host = uri.host&.downcase
    host.presence
  rescue URI::InvalidURIError
    nil
  end

  def self.allowed?(host)
    proper_gov_uk_host?(host) || gov_uk_allow_list_host?(host) || external_allow_list_host?(host)
  end

  def self.proper_gov_uk_host?(host)
    GOV_UK_CANONICAL_HOSTS.include?(host)
  end

  def self.gov_uk_allow_list_host?(host)
    # If it's a publishing.service.gov.uk host, it must only be an assets host
    if host.end_with?(".publishing.service.gov.uk")
      return GOV_UK_ASSETS_HOSTS.include?(host)
    end

    # Otherwise allow any other *.gov.uk domain
    host.end_with?(".gov.uk")
  end

  def self.external_allow_list_host?(host)
    host.end_with?(*EXTERNAL_HOST_ALLOW_LIST) ||
      EXTERNAL_HOST_ALLOW_LIST.any? { |domain| host == domain.delete_prefix(".") }
  end
end
