module Edition::Publishing
  extend ActiveSupport::Concern

  included do
    validates :published_at, :first_published_at, presence: true, if: -> edition { edition.published? }
    validate :change_note_present!, if: :change_note_required?

    scope :first_published_since, -> time { where(arel_table[:first_published_at].gt(time)) }
    scope :first_published_during, -> period { where(first_published_at: period) }
    scope :significant_change, where(minor_change: false)
  end

  module ClassMethods
    def by_published_at
      order(arel_table[:published_at].desc)
    end

    def by_first_published_at
      order(arel_table[:first_published_at].desc)
    end

    def latest_published_at
      published.maximum(:published_at)
    end
  end

  def first_published_version?
    published_major_version.nil? || published_major_version == 1
  end

  def published_version
    if published_major_version and published_minor_version
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
    if change_note.blank? and !minor_change
      errors[:change_note] = "can't be blank"
    end
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
    elsif !user.departmental_editor?
      "Only departmental editors can publish"
    end
  end

  def reason_to_prevent_publication_by(user, options = {})
    reason_to_prevent_approval_by(user, options)
  end

  def reasons_to_prevent_unpublication_by(user)
    errors = []
    errors << "Only GDS editors can unpublish" unless user.gds_editor?
    errors << "This edition has not been published" unless published?
    errors
  end

  def publish_as(user, options = {})
    if publishable_by?(user, options)
      self.published_at = Time.zone.now unless self.minor_change?
      self.first_published_at ||= published_at
      self.access_limited = nil
      if ! scheduled?
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
      unpublish!
      editorial_remarks.create!(author: user, body: "Reset to draft")
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
