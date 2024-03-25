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
    if record.parsed_url.host.present? && !govuk_url_regex.match?(record.parsed_url.host)
      raise URI::InvalidURIError
    end
  end

  def validate_must_reference_govuk_page(record)
    record.content_item.present?
  end

private

  def govuk_url_regex
    /(publishing.service|www).gov.uk\Z/
  end
end
