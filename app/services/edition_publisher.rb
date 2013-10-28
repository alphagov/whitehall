class EditionPublisher
  attr_reader :edition, :options, :notifier

  def initialize(edition, options={})
    @edition = edition
    @notifier = options.delete(:notifier)
    @options = options
  end

  def perform!
    if can_perform?
      prepare_edition
      fire_transition!
      edition.archive_previous_editions!
      notify!
      true
    end
  end

  def can_perform?
    !failure_reason
  end

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

  def past_participle
    "#{verb}ed".humanize.downcase
  end

private

  def notify!
    notifier && notifier.publish(verb, edition, options)
  end

  def prepare_edition
    edition.access_limited  = false
    edition.major_change_published_at = Time.zone.now unless edition.minor_change?
    edition.make_public_at(edition.major_change_published_at)
    edition.increment_version_number
  end

  def fire_transition!
    edition.public_send("#{verb}!")
  end

  def can_transition?
    edition.public_send("can_#{verb}?")
  end
end
