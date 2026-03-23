class GovUkUrlValidator < ActiveModel::Validator
  def validate(record)
    return if record.url.blank?

    validate_must_be_valid_govuk_host(record)
    validate_must_reference_govuk_page(record)
  rescue URI::InvalidURIError
    record.errors.add(:url, "must be a valid GOV.UK URL")
  rescue GdsApi::HTTPNotFound
    record.errors.add(:url, "must reference a GOV.UK page")
  rescue GdsApi::HTTPIntermittentServerError
    record.errors.add(:base, "Link lookup failed, please try again later")
  end

  def validate_must_be_valid_govuk_host(record)
    if record.parsed_url.host.present? && !GOVUK_URL_REGEX.match?(record.parsed_url.host)
      raise URI::InvalidURIError
    end
  end

  def validate_must_reference_govuk_page(record)
    record.content_item.present?
  end

  GOVUK_URL_REGEX = /(publishing\.service|www)\.gov\.uk\z/
  private_constant :GOVUK_URL_REGEX
end
