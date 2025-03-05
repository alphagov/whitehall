require "data_hygiene/govspeak_link_validator"

class EditionScheduler < EditionService
  def verb
    "schedule"
  end

  def past_participle
    "scheduled"
  end

  def failure_reason
    @failure_reason ||= if !edition.valid?
                          "This edition is invalid: #{edition.errors.full_messages.to_sentence}"
                        elsif !can_transition?
                          "An edition that is #{edition.current_state} cannot be #{past_participle}"
                        elsif edition.scheduled_publication.blank?
                          "This edition does not have a scheduled publication date set"
                        elsif scheduled_publication_is_not_within_cache_limit?
                          "Scheduled publication date must be at least #{Whitehall.default_cache_max_age / 60} minutes from now"
                        elsif govspeak_link_errors.any?
                          "This edition contains links which violate linking guidelines. #{govspeak_link_errors.pluck(:fix).uniq.join(' ')}"
                        end
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
