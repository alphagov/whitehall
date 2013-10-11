module Edition::Publishing
  extend ActiveSupport::Concern

  included do
    has_one :unpublishing, dependent: :destroy

    validates :major_change_published_at, presence: true, if: :published?
    validate :change_note_present!, if: :change_note_required?
    validate :attachment_passed_virus_scan!, if: :virus_check_required?

    attr_accessor :skip_virus_status_check

    scope :significant_change, where(minor_change: false)
  end

  module ClassMethods
    def by_major_change_published_at
      order(arel_table[:major_change_published_at].desc)
    end

    def unpublished_as(slug)
      document = Document.at_slug(document_type, slug)
      document && document.latest_edition && document.latest_edition.unpublishing
    end
  end

  def first_published_version?
    published_major_version.nil? || published_major_version == 1
  end

  def published_version
    if published_major_version && published_minor_version
      "#{published_major_version}.#{published_minor_version}"
    end
  end

  def change_note_required?
    if deleted? || archived?
      false
    elsif draft? && new_record?
      false
    else
      other_editions.published.any?
    end
  end

  def change_note_present!
    if change_note.blank? && !minor_change
      errors[:change_note] = "can't be blank"
    end
  end

  def virus_check_required?
    allows_attachments? && published? && !skip_virus_status_check
  end

  def attachment_passed_virus_scan!
    errors.add(:attachments, "must have passed virus scanning.") unless valid_virus_state?
  end

  def reason_to_prevent_unpublication
    if !published?
      "This edition has not been published"
    elsif other_draft_editions.any?
      "There is already a draft edition of this document. You must remove it before you can unpublish this edition."
    end
  end

  def perform_unpublish
    if reason = reason_to_prevent_unpublication
      errors.add(:base, reason)
      false
    else
      decrement_version_numbers
      if unpublishing && unpublishing.valid?
        unpublish! and unpublishing.save
      else
        errors.add(:base, unpublishing.errors.full_messages.join) if unpublishing
        false
      end
    end
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
      self.published_major_version = Edition.unscoped.where(document_id: document_id).maximum(:published_major_version) || 1
      self.published_minor_version = (Edition.unscoped.where(document_id: document_id, published_major_version: published_major_version).maximum(:published_minor_version) || -1) + 1
    else
      self.published_major_version = (Edition.unscoped.where(document_id: document_id).maximum(:published_major_version) || 0) + 1
      self.published_minor_version = 0
    end
  end

private

  def set_publishing_attributes_and_increment_version_numbers
    self.access_limited = false
    increment_version_number
    self.major_change_published_at = Time.zone.now unless minor_change?
    make_public_at(major_change_published_at)
  end

  def decrement_version_numbers
    if minor_change?
      self.published_minor_version = self.published_minor_version - 1
    elsif first_published_version?
      self.published_major_version = nil
      self.published_minor_version = nil
    else
      self.published_major_version = self.published_major_version - 1
      self.published_minor_version = (Edition.unscoped.where(document_id: document_id).where(published_major_version: self.published_major_version).maximum(:published_minor_version) || 0)
    end
  end
end
