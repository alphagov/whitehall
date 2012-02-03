module Document::Publishing
  extend ActiveSupport::Concern

  included do
    validates :published_at, :first_published_at, presence: true, if: -> document { document.published? }

    scope :first_published_since, -> time { where(arel_table[:first_published_at].gt(time)) }
    scope :first_published_during, -> period { where(first_published_at: period) }
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

  def publishable_by?(user, options = {})
    reason_to_prevent_publication_by(user, options).nil?
  end

  def change_note_required?
    document_identity.published_document.present?
  end

  def reason_to_prevent_publication_by(user, options = {})
    if !valid?
      "This edition is invalid. Edit the edition to fix validation problems"
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
    elsif change_note_required? && change_note.blank? && !options[:assuming_presence_of_change_note]
      "Change note can't be blank"
    end
  end

  def publish_as(user, options = {})
    if publishable_by?(user, options)
      self.lock_version = lock_version
      self.published_at = Time.zone.now
      self.first_published_at ||= published_at
      self.force_published = options[:force]
      publish!
      true
    else
      errors.add(:base, reason_to_prevent_publication_by(user, options))
      false
    end
  end
end