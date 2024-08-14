require "data_hygiene/govspeak_link_validator"

class EditionPublisher < EditionService
  def failure_reason
    @failure_reason ||= failure_reasons.first
  end

  def failure_reasons
    return @failure_reasons if @failure_reasons

    reasons = []
    reasons << "This edition is invalid: #{edition.errors.full_messages.to_sentence}" unless edition.valid?
    reasons << "This edition contains links which violate linking guidelines" if govspeak_link_errors.any?
    reasons << "An edition that is #{edition.current_state} cannot be #{past_participle}" unless can_transition?
    reasons << "Scheduled editions cannot be published. This edition is scheduled for publication on #{edition.scheduled_publication}" if scheduled_for_publication?

    @failure_reasons = reasons
  end

  def govspeak_link_errors
    @govspeak_link_errors ||= DataHygiene::GovspeakLinkValidator.new(edition.body).errors
  end

  def verb
    "publish"
  end

private

  def prepare_edition
    flag_if_political_content!
    edition.access_limited = false
    edition.major_change_published_at = Time.zone.now unless edition.minor_change?
    edition.make_public_at(edition.major_change_published_at)
    edition.increment_version_number
  end

  def fire_transition!
    super
    supersede_previous_editions!
    delete_unpublishing!
  end

  def editions_to_supersede
    edition.document.editions
      .where(state: %i[published unpublished])
      .excluding(edition)
  end

  def supersede_previous_editions!
    editions_to_supersede.each do |edition|
      edition.supersede
      edition.save!(validate: false)
    end
  end

  def delete_unpublishing!
    edition.unpublishing.destroy! if edition.unpublishing.present?
  end

  def scheduled_for_publication?
    # Just using edition.scheduled? misses submitted editions
    edition.scheduled_publication.present?
  end

  def flag_if_political_content!
    return if edition.document.live?
    return unless PoliticalContentIdentifier.political?(edition)

    edition.government = edition.default_government
  end
end
