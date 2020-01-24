class GovUkUrlValidator < ActiveModel::Validator
  def validate(record)
    return if record.url.blank?

    validate_must_be_valid_govuk_host(record)
    validate_must_reference_govuk_page(record)
    validate_link_lookup(record)
  rescue URI::InvalidURIError
    record.errors.add(:url, "must be a valid GOV.UK URL")
  rescue GdsApi::HTTPNotFound
    record.errors.add(:url, "must reference a GOV.UK page")
  rescue GdsApi::HTTPIntermittentServerError
    record.errors.add(:base, "Link lookup failed, please try again later")
  end

private

  def validate_must_be_valid_govuk_host(record)
    if parse_url(record.url).host.present? && !valid_host?(record)
      raise URI::InvalidURIError
    end
  end

  def validate_must_reference_govuk_page(record)
    unless content_id(record)
      raise GdsApi::HTTPNotFound.new(404)
    end
  end

  def validate_link_lookup(record)
    Services.publishing_api.get_content(content_id(record)).to_h
  end

  def valid_host?(record)
    parse_url(record.url).host =~ /(publishing.service|www).gov.uk\Z/
  end

  def content_id(record)
    Services.publishing_api.lookup_content_id(
      base_path: parse_url(record.url).path,
      with_drafts: true,
    )
  end

  def parse_url(url)
    URI.parse(url)
  end
end
