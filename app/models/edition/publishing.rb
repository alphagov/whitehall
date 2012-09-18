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

  def publishable_by?(user, options = {})
    reason_to_prevent_publication_by(user, options).nil?
  end

  def first_edition?
    first_published_at && first_published_at == published_at
  end

  def change_note_required?
    if deleted?
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
    end
  end

  def publish_as(user, options = {})
    if publishable_by?(user, options)
      self.published_at = if self.minor_change && latest_published_edition
        latest_published_edition.published_at
      else
        Time.zone.now
      end
      self.first_published_at ||= published_at
      self.force_published = options[:force]
      publish!
      true
    else
      errors.add(:base, reason_to_prevent_publication_by(user, options))
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
