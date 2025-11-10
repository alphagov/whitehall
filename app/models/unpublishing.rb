require "securerandom"

class Unpublishing < ApplicationRecord
  belongs_to :edition

  validates :edition, :unpublishing_reason, :document_type, :slug, presence: true
  validates :explanation, presence: { message: "must be provided when withdrawing", if: :withdrawn? }
  validates :alternative_url, presence: { message: "must be provided to redirect the document", if: :redirect? }
  validates :alternative_url, uri: true, allow_blank: true
  validates :alternative_url, gov_uk_url_format: true, allow_blank: true
  validate :redirect_not_circular

  after_initialize :ensure_presence_of_content_id

  before_save :set_unpublished_at

  before_validation :strip_alternative_url

  def strip_alternative_url
    alternative_url.strip! if alternative_url.present?
  end

  def self.from_slug(slug, type)
    where(slug:, document_type: type.to_s).last
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

  def reason_as_class
    case unpublishing_reason
    when UnpublishingReason::PublishedInError
      "published_in_error"
    when UnpublishingReason::Consolidated
      "consolidated"
    when UnpublishingReason::Withdrawn
      "withdrawn"
    end
  end

  def reason_may_require_explanation?
    [UnpublishingReason::PublishedInError, UnpublishingReason::Withdrawn].include?(unpublishing_reason)
  end

  def document_path
    edition.public_path.gsub(edition.slug, slug)
  end

  def document_url
    edition.public_url.gsub(edition.slug, slug)
  end

  # Because the edition may have been deleted, we need to find it unscoped to
  # get around the default scope.
  def edition
    Edition.unscoped.find(edition_id) if edition_id
  end

  delegate :translated_locales, to: :edition

  def alternative_path
    return if alternative_uri.nil?

    return alternative_uri.to_s unless GovUkUrlFormatValidator.matches_gov_uk?(alternative_uri)

    path = alternative_uri.path
    path << "##{alternative_uri.fragment}" if alternative_uri.fragment.present?
    path
  end

private

  def alternative_uri
    @alternative_uri ||= begin
      return if alternative_url.nil?

      Addressable::URI.parse(alternative_url)
    rescue URI::InvalidURIError, Addressable::URI::InvalidURIError
      nil
    end
  end

  def redirect_not_circular
    if alternative_uri.present? && (document_path == alternative_uri.path)
      errors.add(:alternative_url, "cannot redirect to itself")
    end
  end

  def ensure_presence_of_content_id
    self.content_id ||= SecureRandom.uuid
  end

  def set_unpublished_at
    self.unpublished_at = Time.zone.now if unpublished_at.blank?
  end
end
