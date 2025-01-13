require "data_hygiene/govspeak_link_validator"

class EditionScheduler < EditionService
  def verb
    "schedule"
  end

  def past_participle
    "scheduled"
  end

  def failure_reason
    # Make sure edition is being validated as though it were scheduled so that change note validation is enabled
    old_state = edition.state
    edition.state = :scheduled

    @failure_reason ||= if !edition.valid?
                          "This edition is invalid: #{edition.errors.full_messages.to_sentence}"
                        elsif !can_transition?
                          "An edition that is #{edition.current_state} cannot be #{past_participle}"
                        elsif edition.scheduled_publication.blank?
                          "This edition does not have a scheduled publication date set"
                        elsif scheduled_publication_is_not_within_cache_limit?
                          "Scheduled publication date must be at least #{Whitehall.default_cache_max_age / 60} minutes from now"
                        elsif DataHygiene::GovspeakLinkValidator.new(edition.body).errors.any?
                          "This edition contains links which violate linking guidelines"
                        end

    edition.state = old_state
    @failure_reason
  end

private

  def fire_transition!
    super
    ScheduledPublishingWorker.queue(edition)
  end

  def scheduled_publication_is_not_within_cache_limit?
    edition.scheduled_publication < Whitehall.default_cache_max_age.from_now
  end
end
