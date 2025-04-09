require "data_hygiene/govspeak_link_validator"

class EditionScheduler < EditionService
  def verb
    "schedule"
  end

  def past_participle
    "scheduled"
  end

  def failure_reason
    @failure_reason ||= failure_reasons.first
  end

  def failure_reasons
    return @failure_reasons if @failure_reasons

    reasons = []
    if !edition.valid?
      reasons << "This edition is invalid: #{edition.errors.full_messages.to_sentence}" unless edition.valid?
    elsif !can_transition?
      reasons << "An edition that is #{edition.current_state} cannot be #{past_participle}"
    elsif edition.scheduled_publication.blank?
      reasons << "This edition does not have a scheduled publication date set"
    elsif scheduled_publication_is_not_within_cache_limit?
      reasons << "Scheduled publication date must be at least #{Whitehall.default_cache_max_age / 60} minutes from now"
    elsif govspeak_link_errors.any?
      reasons << "This edition contains links which violate linking guidelines."
      reasons.concat govspeak_link_errors.pluck(:fix).uniq
    end
    @failure_reasons = reasons
  end

private

  def govspeak_link_errors
    @govspeak_link_errors ||= DataHygiene::GovspeakLinkValidator.new(edition.body).errors
  end

  def fire_transition!
    super
    ScheduledPublishingWorker.queue(edition)
  end

  def scheduled_publication_is_not_within_cache_limit?
    edition.scheduled_publication < Whitehall.default_cache_max_age.from_now
  end
end
