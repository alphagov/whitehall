module Edition::ScheduledPublishing
  extend ActiveSupport::Concern

  included do
    validate :scheduled_publication_is_in_the_future, if: :scheduled_publication_must_be_in_the_future?
  end

  module ClassMethods
    def due_for_publication(within_time = 0)
      cutoff = Time.zone.now + within_time
      scheduled.where(arel_table[:scheduled_publication].lteq(cutoff))
    end

    def scheduled_for_publication_as(slug)
      document = Document.at_slug(document_type, slug)
      document && document.scheduled_edition
    end
  end

  def schedulable_by?(user, options = {})
    reason_to_prevent_scheduling_by(user, options).nil?
  end

  def reason_to_prevent_scheduling_by(user, options = {})
    if scheduled?
      "This edition is already scheduled for publication"
    elsif reason = reason_to_prevent_approval(options)
      reason
    elsif scheduled_publication.blank?
      "This edition does not have a scheduled publication date set"
    end
  end

  def schedule_as(user, options = {})
    if schedulable_by?(user, options)
      self.force_published = options[:force]
      schedule!
      true
    else
      errors.add(:base, reason_to_prevent_scheduling_by(user, options))
      false
    end
  end

  def reason_to_prevent_unscheduling
    "This edition is not scheduled for publication" if !scheduled?
  end

  def unschedule_as(user)
    if reason = reason_to_prevent_unscheduling
      errors.add(:base, reason)
      false
    else
      self.force_published = false
      unschedule!
    end
  end

  private

  def scheduled_publication_is_in_the_future
    if scheduled_publication.present? && scheduled_publication < Whitehall.default_cache_max_age.from_now
      errors[:scheduled_publication] << "date must be at least #{Whitehall.default_cache_max_age / 60} minutes from now"
    end
  end

  def scheduled_publication_must_be_in_the_future?
    (draft? && state_was == 'draft') || submitted? || (state_was == 'rejected' && rejected?)
  end
end
