class Unpublishing < ActiveRecord::Base
  belongs_to :edition

  validates :edition, :unpublishing_reason, :document_type, :slug, presence: true
  validates :explanation, presence: { message: "must be provided when archiving", if: :archived? }
  validates :alternative_url, presence: { message: "must be provided to redirect the document", if: :redirect? }
  validates :alternative_url, uri: true, allow_blank: true
  validates_format_of :alternative_url,
    with: %r(^#{Whitehall.public_protocol}://#{Whitehall.public_host}?.*),
    message: "must be in the form of #{Whitehall.public_protocol}://#{Whitehall.public_host}/example",
    allow_blank: true
  validate :redirect_not_circular

  def self.from_slug(slug, type)
    where(slug: slug, document_type: type.to_s).first
  end

  def redirect?
    redirect || unpublishing_reason == UnpublishingReason::Consolidated
  end

  def archived?
    unpublishing_reason == UnpublishingReason::Archived
  end

  def unpublishing_reason
    UnpublishingReason.find_by_id unpublishing_reason_id
  end

  def reason_as_sentence
    unpublishing_reason.as_sentence
  end

  def edition_url
    Whitehall.url_maker.public_document_url(edition)
  end

  def redirect_not_circular
    if alternative_url.present?
      if edition_url == alternative_url
        errors.add(:alternative_url, "cannot redirect to itself")
      end
    end
  end
end
