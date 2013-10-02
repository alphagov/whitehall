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
    allows_attachments? && published? && !skip_virus_status_check
  end

  def attachment_passed_virus_scan!
    errors.add(:attachments, "must have passed virus scanning.") unless valid_virus_state?
  end

  def publishable_by?(user, options = {})
    reason_to_prevent_publication_by(user, options).nil?
  end

  def unpublishable_by?(user)
    reasons_to_prevent_unpublication_by(user).empty?
  end

  def approvable_by?(user, options = {})
    reason_to_prevent_approval_by(user, options).nil?
  end

  def reason_to_prevent_approval_by(user, options = {})
    if !valid?
      "This edition is invalid. Edit the edition to fix validation problems"
    elsif imported?
      "This edition is not ready for publishing"
    elsif published?
      "This edition has already been published"
    elsif archived?
      "This edition has been archived"
    elsif deleted?
      "This edition has been deleted"
    elsif rejected?
      "This edition has been rejected"
    elsif !submitted? && !options[:force]
      "Not ready for publication"
    elsif user == creator && !options[:force]
      "You are not the second set of eyes"
    elsif !enforcer(user).can?(options[:force] ? :force_publish : :publish)
      "Only departmental editors can publish"
    end
  end

  def reason_to_prevent_publication_by(user, options = {})
    reason_to_prevent_approval_by(user, options)
  end

  def reasons_to_prevent_unpublication_by(user)
    errors = []
    errors << "Only GDS editors can unpublish" unless enforcer(user).can?(:unpublish)
    errors << "This edition has not been published" unless published?
    unless other_draft_editions.empty?
      errors << "There is already a draft edition of this document. You must remove it before you can unpublish this edition."
    end
    errors
  end

  def rejectable_by?(user)
    submitted? && enforcer(user).can?(:reject)
  end

  def approvable_retrospectively_by?(user)
    !reason_to_prevent_retrospective_approval_by(user)
  end

  def reason_to_prevent_retrospective_approval_by(user)
    if !force_published?
      "This document has not been force-published"
    elsif scheduled_by && user == scheduled_by
      "You are not allowed to retrospectively approve this document, since you force-scheduled it"
    elsif user == published_by
      "You are not allowed to retrospectively approve this document, since you force-published it"
    elsif !enforcer(user).can?(:approve)
      "Only departmental editors can retrospectively approve a force-published document"
    end
  end

  def publish_as(user, options = {})
    if publishable_by?(user, options)
      self.major_change_published_at = Time.zone.now unless self.minor_change?
      make_public_at(major_change_published_at)
      self.access_limited = false
      unless scheduled?
        self.force_published = options[:force]
      end
      if minor_change?
        self.published_major_version = Edition.unscoped.where(document_id: document_id).maximum(:published_major_version) || 1
        self.published_minor_version = (Edition.unscoped.where(document_id: document_id, published_major_version: published_major_version).maximum(:published_minor_version) || -1) + 1
      else
        self.published_major_version = (Edition.unscoped.where(document_id: document_id).maximum(:published_major_version) || 0) + 1
        self.published_minor_version = 0
      end
      publish!
      true
    else
      errors.add(:base, reason_to_prevent_publication_by(user, options))
      false
    end
  end

  def unpublish_as(user)
    if unpublishable_by?(user)
      if minor_change?
        self.published_minor_version = self.published_minor_version - 1
      elsif first_published_version?
        self.published_major_version = nil
        self.published_minor_version = nil
      else
        self.published_major_version = self.published_major_version - 1
        self.published_minor_version = (Edition.unscoped.where(document_id: document_id).where(published_major_version: self.published_major_version).maximum(:published_minor_version) || 0)
      end
      if unpublishing && unpublishing.valid?
        unpublish!
        editorial_remarks.create!(author: user, body: "Reset to draft")
        unpublishing.save
      else
        errors.add(:base, unpublishing.errors.full_messages.join) if unpublishing
        false
      end
    else
      reasons_to_prevent_unpublication_by(user).each do |reason|
        errors.add(:base, reason)
      end
      false
    end
  end

  def approve_retrospectively_as(user)
    if approvable_retrospectively_by?(user)
      self.force_published = false
      save!
    else
      errors.add(:base, reason_to_prevent_retrospective_approval_by(user))
      false
    end
  end
end
