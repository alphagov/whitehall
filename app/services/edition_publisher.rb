class EditionPublisher < EditionService
  def failure_reason
    @failure_reason ||= if !edition.valid?
      "This edition is invalid: #{edition.errors.full_messages.to_sentence}"
    elsif !can_transition?
      "An edition that is #{edition.current_state} cannot be #{past_participle}"
    elsif edition.scheduled_publication.present? && Time.zone.now < edition.scheduled_publication
      "This edition is scheduled for publication on #{edition.scheduled_publication.to_s}, and may not be #{past_participle} before"
    end
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
end
