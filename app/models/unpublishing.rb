require "securerandom"

class Unpublishing < ApplicationRecord
  belongs_to :edition

  validates :edition, :unpublishing_reason, :document_type, :slug, presence: true
  validates :explanation, presence: { message: "must be provided when withdrawing", if: :withdrawn? }
  validates :alternative_url, presence: { message: "must be provided to redirect the document", if: :redirect? }
  validates :alternative_url, uri: true, allow_blank: true
  validates :alternative_url, gov_uk_url: true, allow_blank: true
  validate :redirect_not_circular

  after_initialize :ensure_presence_of_content_id

  before_validation :strip_alternative_url

  def strip_alternative_url
    alternative_url.strip! if alternative_url.present?
  end

  def self.from_slug(slug, type)
    where(slug: slug, document_type: type.to_s).last
  end

  def redirect?
    redirect || unpublishing_reason == UnpublishingReason::Consolidated
  end

  def withdrawn?
    unpublishing_reason == UnpublishingReason::Withdrawn
  end

  def unpublishing_reason
    UnpublishingReason.find_by_id unpublishing_reason_id
  end

  def unpublishing_reason=(new_unpublishing_reason)
    self.unpublishing_reason_id = new_unpublishing_reason.try(:id)
  end

  def reason_as_sentence
    unpublishing_reason.as_sentence
  end

  def document_path
    Whitehall.url_maker.public_document_path(edition, id: slug)
  end

  def document_url
    Whitehall.url_maker.public_document_url(edition, id: slug)
  end

  # Because the edition may have been deleted, we need to find it unscoped to
  # get around the default scope.
  def edition
    Edition.unscoped.find(edition_id) if edition_id
  end

  def translated_locales
    edition.translated_locales
  end

  def alternative_path
    return if alternative_uri.nil?

    path = alternative_uri.path
    path << "##{alternative_uri.fragment}" if alternative_uri.fragment.present?
    path
  end

private

  def alternative_uri
    @alternative_uri ||= begin
      return if alternative_url.nil?

      Addressable::URI.parse(alternative_url)
    rescue URI::InvalidURIError
      nil
    end
  end

  def redirect_not_circular
    if alternative_uri.present?
      if document_path == alternative_uri.path
        errors.add(:alternative_url, "cannot redirect to itself")
      end
    end
  end

  def ensure_presence_of_content_id
    self.content_id ||= SecureRandom.uuid
  end
end
