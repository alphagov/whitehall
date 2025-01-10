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
    elsif should_check_current_user_will_retain_access? && access_limit_excludes_current_user?
      "Access can only be limited by users belonging to an organisation tagged to the document"
    elsif !edition.valid?(Flipflop.remove_draft_change_note_validation? && :save_draft)
      "This edition is invalid: #{edition.errors.full_messages.to_sentence}"
    end
  end

  def verb
    "update_draft"
  end

private

  def should_check_current_user_will_retain_access?
    @options[:current_user].present? && edition.access_limited?
  end

  def access_limit_excludes_current_user?
    edition.limits_access_via_organisations? && edition.edition_organisations.map(&:organisation_id).exclude?(@options[:current_user].organisation.id)
  end
end
