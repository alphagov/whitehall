class BrexitNoDealContentNoticeLink < ApplicationRecord
  belongs_to :edition

  validates :title,
            length: { maximum: 255 },
            presence: true,
            if: proc { |link| link.url.present? }

  validates :url,
            presence: true,
            if: proc { |link| link.title.present? }

  validates :url, uri: true, if: :is_external?

  validates_with GovUkUrlValidator, if: :is_internal?

  validate :link_title_is_not_a_url?

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

  def link_title_is_not_a_url?
    errors.add(:title, "can't be a URL") if url_regex.match?(title)
  end

  def govuk_url_regex
    /(publishing.service|www).gov.uk\Z/
  end

  def url_regex
    /https?:\/\/[\S]+/
  end

  def host
    return URI.parse("https://#{url}").host if url.start_with?("www.")

    URI.parse(url).host
  end
end
