class EditionForcePublisher < EditionPublisher

  def failure_reason
    @failure_reason ||= if !edition.valid?
      "This edition is invalid: #{edition.errors.full_messages.to_sentence}"
    elsif edition.scheduled_publication.present? && Time.zone.now < edition.scheduled_publication
      "This edition is scheduled for publication on #{edition.scheduled_publication.to_s} so cannot be force published"
    elsif options[:reason].blank?
      'You cannot force publish an edition without a reason'
    elsif !edition.can_force_publish?
      "An edition that is #{edition.current_state} cannot be force published"
    end
  end

  def default_subscribers
    super + [Edition::ForcePublishLogger]
  end

private

  def prepare_edition
    edition.force_published = true
    super
  end

  def fire_transition!
    edition.force_publish!
  end
end
