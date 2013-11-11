class EditionPublisher < EditionService
  def failure_reason
    @failure_reason ||= failure_reasons.first
  end

  def failure_reasons
    return @failure_reasons if @failure_reasons

    reasons = []
    reasons << "This edition is invalid: #{edition.errors.full_messages.to_sentence}" unless edition.valid?
    reasons << "This edition contains bad links" if govspeak_link_errors.any?
    reasons << "An edition that is #{edition.current_state} cannot be #{past_participle}" unless can_transition?
    reasons << "This edition is scheduled for publication on #{edition.scheduled_publication.to_s}, and may not be #{past_participle} before" if scheduled_for_publication?

    @failure_reasons = reasons
  end

  def govspeak_link_errors
    @govspeak_link_errors ||= DataHygiene::GovspeakLinkValidator.new(edition.body).errors
  end

  def verb
    'publish'
  end

private

  def prepare_edition
    edition.access_limited  = false
    edition.major_change_published_at = Time.zone.now unless edition.minor_change?
    edition.make_public_at(edition.major_change_published_at)
    edition.increment_version_number
  end

  def fire_transition!
    super
    supersede_previous_editions!
  end

  def supersede_previous_editions!
    edition.document.editions.published.each do |e|
      e.supersede! unless e == edition
    end
  end

  def scheduled_for_publication?
    edition.scheduled_publication.present? && Time.zone.now < edition.scheduled_publication
  end
end
