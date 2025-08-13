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

  def matches_allow_list?(value)
    uri = URI.parse(value)
    uri.host&.end_with?(*EXTERNAL_HOST_ALLOW_LIST)
  rescue URI::InvalidURIError
    false
  end
end
