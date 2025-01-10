class DraftTranslationUpdater < EditionService
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
    elsif !edition.valid?(Flipflop.remove_draft_change_note_validation? && :save_draft)
      "This edition is invalid: #{edition.errors.full_messages.to_sentence}"
    end
  end

  def verb
    "update_draft_translation"
  end
end
