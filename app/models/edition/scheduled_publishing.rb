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
    else
      reason_to_prevent_approval_by(user, options) or if scheduled_publication.blank?
        "This edition does not have a scheduled publication date set"
      end
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

  def unschedulable_by?(user)
    reason_to_prevent_unscheduling_by(user).nil?
  end

  def reason_to_prevent_unscheduling_by(user)
    if !scheduled?
      "This edition is not scheduled for publication"
    elsif !enforcer(user).can?(:update)
      "You do not have permission to unschedule this publication"
    end
  end

  def unschedule_as(user)
    if unschedulable_by?(user)
      self.force_published = false
      unschedule!
      true
    else
      errors.add(:base, reason_to_prevent_unscheduling_by(user))
      false
    end
  end

  def reason_to_prevent_publication_by(user, options = {})
    if scheduled?
      if Time.zone.now < scheduled_publication
        "This edition is scheduled for publication on #{scheduled_publication.to_s}, and may not be published before"
      elsif !valid?
        "Can't publish invalid scheduled publication"
      elsif !user.can_publish_scheduled_editions?
        "User must have permission to publish scheduled publications"
      end
    elsif scheduled_publication.present?
      "Can't publish this edition immediately as it has a scheduled publication date. Schedule it for publication or remove the scheduled publication date."
    else
      super
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
