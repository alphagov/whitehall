class DraftEditionUpdater < EditionService
  def perform!
    if can_perform?
      update_publishing_api!
      notify!
      true
    end
  end

  def failure_reason
    if !edition.pre_publication?
      "A #{edition.state} edition may not be updated."
    elsif !edition.valid?
      "This edition is invalid: #{edition.errors.full_messages.to_sentence}"
    end
  end

  def verb
    'update_draft'
  end
end
