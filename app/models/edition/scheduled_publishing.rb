module Edition::ScheduledPublishing
  extend ActiveSupport::Concern

  module InstanceMethods
    def schedulable_by?(user, options = {})
      reason_to_prevent_scheduling_by(user, options).nil?
    end

    def reason_to_prevent_scheduling_by(user, options = {})
      reason_to_prevent_approval_by(user, options) or if scheduled_publication.blank?
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

    def reason_to_prevent_publication_by(user, options = {})
      super or if scheduled_publication.present?
        if !scheduled? or Time.zone.now < scheduled_publication
          "This edition is scheduled for publication on #{scheduled_publication.to_s}, and may not be published before"
        end
      end
    end
  end
end
