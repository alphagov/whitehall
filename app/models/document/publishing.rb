module Document::Publishing
  extend ActiveSupport::Concern

  included do
    validates :published_at, presence: true, if: -> document { document.published? }
  end

  def publishable_by?(user)
    reason_to_prevent_publication_by(user).nil?
  end

  def force_publishable_by?(user)
    reason_to_prevent_publication_by(user, force: true).nil?
  end

  def reason_to_prevent_publication_by(user, options = {})
    if published?
      "This edition has already been published"
    elsif archived?
      "This edition has been archived"
    elsif deleted?
      "This edition has been deleted"
    elsif rejected?
      "This edition has been rejected"
    elsif !submitted? && !options[:force]
      "Not ready for publication"
    elsif user == author && !options[:force]
      "You are not the second set of eyes"
    elsif !user.departmental_editor?
      "Only departmental editors can publish"
    end
  end

  def publish_as(user, options = {})
    if options[:force] && force_publishable_by?(user) || publishable_by?(user)
      self.lock_version = lock_version
      self.published_at = Time.zone.now
      publish!
      true
    else
      errors.add(:base, reason_to_prevent_publication_by(user, options))
      false
    end
  end
end