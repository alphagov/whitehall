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
    elsif edition.access_limited? && @options[:current_user].present? && edition.edition_organisations.map(&:organisation_id).exclude?(@options[:current_user].organisation.id)
      "Access can only be limited by users belonging to an organisation tagged to the document"
    elsif !edition.valid?
      "This edition is invalid: #{edition.errors.full_messages.to_sentence}"
    end
  end

  def verb
    "update_draft"
  end
end
