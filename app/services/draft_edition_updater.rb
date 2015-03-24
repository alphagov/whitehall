class DraftEditionUpdater < EditionService

  def perform!
    if can_perform?
      notify!
      true
    end
  end

  def failure_reason
    if !edition.valid?
      "This edition is invalid: #{edition.errors.full_messages.to_sentence}"
    end
  end

end
