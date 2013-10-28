module Edition::Publishing
  extend ActiveSupport::Concern

  included do
    has_one :unpublishing, dependent: :destroy

    validates :major_change_published_at, presence: true, if: -> edition { edition.published? }
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
    allows_attachments? && published? && (! skip_virus_status_check)
  end

  def attachment_passed_virus_scan!
    errors.add(:attachments, "must have passed virus scanning.") unless valid_virus_state?
  end

  def reason_to_prevent_publication
    if !valid?
      "This edition is invalid. Edit the edition to fix validation problems"
    elsif draft?
      "Not ready for publication"
    elsif published?
      "This edition has already been published"
    elsif !can_publish?
      "This edition has been #{current_state}"
    elsif scheduled? && Time.zone.now < scheduled_publication
        "This edition is scheduled for publication on #{scheduled_publication.to_s}, and may not be published before"
    elsif scheduled_publication.present? && Time.zone.now < scheduled_publication
      "Can't publish this edition immediately as it has a scheduled publication date. Schedule it for publication or remove the scheduled publication date."
    end
  end

  def reason_to_prevent_force_publication
    if !valid?
      "This edition is invalid. Edit the edition to fix validation problems"
    elsif published?
      "This edition has already been published"
    elsif !can_force_publish?
      "This edition has been #{current_state}"
    end
  end

  def reason_to_prevent_unpublication
    if !published?
      "This edition has not been published"
    elsif other_draft_editions.any?
      "There is already a draft edition of this document. You must remove it before you can unpublish this edition."
    end
  end

  def perform_publish
    if reason = reason_to_prevent_publication
      errors.add(:base, reason)
      false
    else
      set_publishing_attributes_and_increment_version_numbers
      publish!
    end
  end

  def perform_force_publish
    if reason = reason_to_prevent_force_publication
      errors.add(:base, reason)
      false
    else
      set_publishing_attributes_and_increment_version_numbers
      self.force_published = true
      force_publish!
    end
  end

  def force_publishable?
    can_force_publish? && scheduled_publication_time_not_set?
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

private

  def set_publishing_attributes_and_increment_version_numbers
    self.access_limited = false
    if minor_change?
      self.published_major_version = Edition.unscoped.where(document_id: document_id).maximum(:published_major_version) || 1
      self.published_minor_version = (Edition.unscoped.where(document_id: document_id, published_major_version: published_major_version).maximum(:published_minor_version) || -1) + 1
    else
      self.major_change_published_at = Time.zone.now
      self.published_major_version = (Edition.unscoped.where(document_id: document_id).maximum(:published_major_version) || 0) + 1
      self.published_minor_version = 0
    end
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
