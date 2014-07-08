class EditionScheduler < EditionService
  def verb
    'schedule'
  end

  def past_participle
    'scheduled'
  end

  def failure_reason
    @failure_reason ||= if !edition.valid?
      "This edition is invalid: #{edition.errors.full_messages.to_sentence}"
     elsif !can_transition?
      "An edition that is #{edition.current_state} cannot be #{past_participle}"
    elsif edition.scheduled_publication.blank?
      "This edition does not have a scheduled publication date set"
    elsif DataHygiene::GovspeakLinkValidator.new(edition.body).errors.any?
      "This edition contains bad links"
    end
  end
end
