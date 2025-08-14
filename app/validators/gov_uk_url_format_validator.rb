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

  # def validate_each(record, attribute, value)
  #   return if value.blank?                # let presence validators handle blank
  #   return if internal_path?(value)       # accept internal paths like "/foo"

  #   # Reuse UriValidator to surface its exact messages (length, scheme, etc.)
  #   # Don't pass our :message option through, so UriValidator uses its own copy.
  #   before = record.errors[attribute].length
  #   UriValidator.new(options.except(:message)).validate_each(record, attribute, value)
  #   added_uri_errors = record.errors[attribute].length > before
  #   return if added_uri_errors             # if syntax invalid, show those errors and stop

  #   # Syntax is OK — now enforce allow-list
  #   unless allowed_host?(value)
  #     record.errors.add(
  #       attribute,
  #       options[:message] || "must be an allowed external URL (or use an internal path like /foo)"
  #     )
  #   end
  # end

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
