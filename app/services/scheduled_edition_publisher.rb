class ScheduledEditionPublisher < EditionPublisher
  def verb
    'publish'
  end

private
  def failure_reasons
    @failure_reasons ||= [].tap do |reasons|
      reasons << 'Only scheduled editions can be published with ScheduledEditionPublisher' unless scheduled_for_publication?
      reasons << "This edition is scheduled for publication on #{edition.scheduled_publication.to_s}, and may not be published before" if too_early_to_publish?
    end
  end

  def scheduled_for_publication?
    edition.scheduled? && super
  end

  def too_early_to_publish?
    scheduled_for_publication? && edition.scheduled_publication > Time.zone.now
  end

  def fire_transition!
    edition.publish
    edition.save(validate: false)
    supersede_previous_editions!
  end
end
