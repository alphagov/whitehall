module Edition::Publishing
  extend ActiveSupport::Concern

  included do
    has_one :unpublishing, dependent: :destroy

    validates :major_change_published_at, presence: true, if: :published?
    validate :change_note_present!, if: :change_note_required?
    validate :attachments_uploaded_to_asset_manager!, if: :attachments_in_asset_manager_check_required?
    validate :images_uploaded_to_asset_manager!, if: :images_in_asset_manager_check_required?
    validates_associated :unpublishing, on: :publish

    scope :significant_change, -> { where(minor_change: false) }
  end

  module ClassMethods
    def by_major_change_published_at
      order(arel_table[:major_change_published_at].desc)
    end

    def unpublished_as(slug)
      document = Document.at_slug(document_type, slug)
      document&.latest_edition&.unpublishing
    end
  end

  def first_published_version?
    published_major_version.nil? || published_major_version == 1
  end

  def first_published_major_version?
    published_major_version == 1 && published_minor_version.zero?
  end

  def published_version
    if published_major_version && published_minor_version
      "#{published_major_version}.#{published_minor_version}"
    end
  end

  def change_note_required?
    return false if new_record?

    pre_publication? && previous_edition.present?
  end

  def change_note_present!
    if change_note.blank? && !minor_change
      errors.add(:change_note, :blank)
    end
  end

  def attachments_in_asset_manager_check_required?
    allows_attachments? && published?
  end

  def attachments_uploaded_to_asset_manager!
    errors.add(:attachments, "must have finished uploading") unless attachments_uploaded_to_asset_manager?
  end

  def images_in_asset_manager_check_required?
    allows_image_attachments? && published?
  end

  def images_uploaded_to_asset_manager!
    errors.add(:images, "must have finished uploading") unless images_uploaded_to_asset_manager?
  end

  def build_unpublishing(attributes = {})
    super(attributes.merge(slug:, document_type: type))
  end

  def approve_retrospectively
    if force_published?
      self.force_published = false
      save!
    else
      errors.add(:base, "This document has not been force-published")
      false
    end
  end

  def increment_version_number
    if minor_change?
      self.published_major_version = Edition.unscoped.where(document_id:).maximum(:published_major_version) || 1
      self.published_minor_version = (Edition.unscoped.where(document_id:, published_major_version:).maximum(:published_minor_version) || -1) + 1
    else
      self.published_major_version = (Edition.unscoped.where(document_id:).maximum(:published_major_version) || 0) + 1
      self.published_minor_version = 0
    end
  end

  def reset_version_numbers
    self.published_major_version = previous_edition.try(:published_major_version)
    self.published_minor_version = previous_edition.try(:published_minor_version)
  end
end
