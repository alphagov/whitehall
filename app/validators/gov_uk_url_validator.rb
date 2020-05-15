class GovUkUrlValidator < ActiveModel::Validator
  def validate(record)
    return if record.url.blank?

    url = parse_url(record.url)

    validate_must_be_valid_govuk_host(url.host)
    validate_must_reference_govuk_page(url.path)
  rescue URI::InvalidURIError
    record.errors.add(:url, "must be a valid GOV.UK URL")
  rescue GdsApi::HTTPNotFound
    record.errors.add(:url, "must reference a GOV.UK page")
  rescue GdsApi::HTTPIntermittentServerError
    record.errors.add(:base, "Link lookup failed, please try again later")
  end

  def validate_must_be_valid_govuk_host(host)
    if host.present? && !valid_govuk_host?(host)
      raise URI::InvalidURIError
    end
  end

  def validate_must_reference_govuk_page(path)
    if content_item_found?(path)
      validate_link_lookup(content_id(path))
    else
      validate_must_reference_guide_subpage(path)
    end
  end

  def validate_must_reference_guide_subpage(path)
    _separator, toplevel_path_segment, *_subpaths = path.split("/")
    content_id = content_id("/#{toplevel_path_segment}")

    if content_id.blank?
      raise GdsApi::HTTPNotFound, 404
    else
      content_item = get_content_item(content_id)

      unless guide?(content_item)
        raise GdsApi::HTTPNotFound, 404
      end
    end
  end

private

  def validate_link_lookup(content_id)
    get_content_item(content_id)
  end

  def guide?(content_item)
    content_item["document_type"] == "guide"
  end

  def valid_govuk_host?(host)
    govuk_url_regex.match?(host)
  end

  def content_item_found?(path)
    content_id(path).present?
  end

  def content_id(path)
    Services.publishing_api.lookup_content_id(
      base_path: path,
      with_drafts: true,
    )
  end

  def get_content_item(content_id)
    Services.publishing_api.get_content(content_id).to_h
  end

  def govuk_url_regex
    /(publishing.service|www).gov.uk\Z/
  end

  def parse_url(url)
    return URI.parse("https://#{url}") if url.start_with?("www.")

    URI.parse(url)
  end
end
