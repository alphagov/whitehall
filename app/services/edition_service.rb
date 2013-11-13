# Abstract base class for edition services
class EditionService
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
      notify!
      true
    end
  end

  def can_perform?
    !failure_reason
  end

  def can_transition?
    edition.public_send("can_#{verb}?")
  end

  def failure_reason
    raise NotImplementedError.new("You must implement failure method.")
  end

  def verb
    raise NotImplementedError.new("You must implement verb method.")
  end

  def past_participle
    "#{verb}ed".humanize.downcase
  end

private

  def notify!
    notifier && notifier.publish(verb, edition, options)
  end

  def prepare_edition
    raise NotImplementedError.new("You must implement prepare_edition method.")
  end

  def fire_transition!
    edition.public_send("#{verb}!")
  end
end
