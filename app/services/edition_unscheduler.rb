class EditionUnscheduler < EditionService
  def verb
    'unschedule'
  end

  def past_participle
    'unscheduled'
  end

  def failure_reason
    "This edition is not scheduled for publication" unless edition.scheduled?
  end

private

  def prepare_edition
    edition.force_published = false
    super
  end

  def fire_transition!
    super
    ScheduledPublishingWorker.dequeue(edition)
  end
end
