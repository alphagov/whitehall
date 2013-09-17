class Unpublishing < ActiveRecord::Base
  include Rails.application.routes.url_helpers
  include PublicDocumentRoutesHelper

  belongs_to :edition

  validates :edition, :unpublishing_reason, :document_type, :slug, presence: true
  validates :alternative_url, presence: {
    message: "must be entered if you want to redirect to it",
    if: -> unpublishing { unpublishing.redirect? }
  }
  validates :alternative_url, uri: true, if: -> unpublishing { unpublishing.redirect? }
  validate :redirect_not_circular

  def self.from_slug(slug, type)
    where(slug: slug, document_type: type.to_s).first
  end

  def unpublishing_reason
    UnpublishingReason.find_by_id unpublishing_reason_id
  end

  def reason_as_sentence
    unpublishing_reason.as_sentence
  end

  def edition_url
    public_document_url(edition)
  end

  def redirect_not_circular
    if alternative_url.present?
      if edition_url == alternative_url
        errors.add(:alternative_url, "cannot redirect to itself")
      end
    end
  end
end
