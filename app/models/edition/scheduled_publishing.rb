module Edition::ScheduledPublishing
  extend ActiveSupport::Concern

  included do
    validate :scheduled_publication_must_be_in_the_future
  end

  module InstanceMethods
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
      super or if scheduled_publication.present?
        if !scheduled? or Time.zone.now < scheduled_publication
          "This edition is scheduled for publication on #{scheduled_publication.to_s}, and may not be published before"
        end
      end
    end

    private

    def scheduled_publication_must_be_in_the_future
      if scheduled_publication.present? && scheduled_publication < Time.zone.now
        errors[:scheduled_publication] << "date must be in the future"
      end
    end
  end
end
