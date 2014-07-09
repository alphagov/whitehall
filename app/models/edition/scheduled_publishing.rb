module Edition::ScheduledPublishing
  extend ActiveSupport::Concern

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
end
