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

  def reason_to_prevent_scheduling
    if !valid?
      "This edition is invalid. Edit the edition to fix validation problems"
    elsif scheduled?
      "This edition is already scheduled for publication"
    elsif !can_schedule?
      "This edition has been #{current_state}"
    elsif scheduled_publication.blank?
      "This edition does not have a scheduled publication date set"
    end
  end

  def reason_to_prevent_force_scheduling
    if !valid?
      "This edition is invalid. Edit the edition to fix validation problems"
    elsif scheduled?
      "This edition is already scheduled for publication"
    elsif !can_force_schedule?
      "This edition has been #{current_state}"
    elsif scheduled_publication.blank?
      "This edition does not have a scheduled publication date set"
    end
  end

  def perform_schedule
    if reason = reason_to_prevent_scheduling
      errors.add(:base, reason)
      false
    else
      schedule!
    end
  end

  def perform_force_schedule
    if reason = reason_to_prevent_force_scheduling
      errors.add(:base, reason)
      false
    else
      self.force_published = true
      force_schedule!
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

  def schedulable?
    can_schedule? && scheduled_publication_time_set?
  end

  def force_schedulable?
    can_force_schedule? && scheduled_publication_time_set?
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
