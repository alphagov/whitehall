class EditionUnpublisher
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

  def failure_reason
    @failure_reason ||= if !edition.valid?
      "This edition is invalid: #{edition.errors.full_messages.to_sentence}"
    elsif !can_transition?
      "An edition that is #{edition.current_state} cannot be #{past_participle}"
    elsif edition.other_draft_editions.any?
      "There is already a draft edition of this document. You must remove it before you can unpublish this edition."
    elsif edition.unpublishing.blank?
      "The reason for unpublishing must be present"
    elsif !edition.unpublishing.valid?
      edition.unpublishing.errors.full_messages.to_sentence
    end
  end

  def verb
    'unpublish'
  end

  def past_participle
    "#{verb}ed".humanize.downcase
  end

private

  def notify!
    notifier && notifier.publish(verb, edition, options)
  end

  def prepare_edition
    edition.force_published = false
    edition.reset_version_numbers
  end

  def fire_transition!
    edition.public_send("#{verb}!")
  end

  def can_transition?
    edition.public_send("can_#{verb}?")
  end
end
