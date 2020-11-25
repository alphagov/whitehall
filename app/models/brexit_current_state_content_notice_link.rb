class BrexitCurrentStateContentNoticeLink < ApplicationRecord
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

  def link_title_is_not_a_url?
    errors.add(:title, "can't be a URL") if url_regex.match?(title)
  end

  def is_external?
    GovUkUrlIdentifier.new(url).is_external?
  end

  def is_internal?
    GovUkUrlIdentifier.new(url).is_internal?
  end

private

  def url_regex
    /https?:\/\/[\S]+/
  end
end
