class GovUkUrlIdentifier
  attr_reader :url

  def initialize(url)
    @url = url
  end

  def is_external?
    !is_internal?
  end

  def is_internal?
    has_govuk_host? || has_no_host?
  end

private

  def has_govuk_host?
    govuk_url_regex.match?(host)
  end

  def has_no_host?
    host.blank?
  end

  def govuk_url_regex
    /(publishing.service|www).gov.uk\Z/
  end

  def host
    return URI.parse("https://#{url}").host if url.start_with?("www.")

    URI.parse(url).host
  end
end
