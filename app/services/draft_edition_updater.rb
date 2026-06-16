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
    elsif !edition.valid?
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
    # Some users may not necessarily belong to an organisation. We should fail-closed for them.
    return true unless @options[:current_user].organisation

    if Flipflop.access_limiting_organisations_ui?
      org_ids = edition.edition_access_limiting_organisations
                       .reject(&:marked_for_destruction?)
                       .map(&:organisation_id)
      org_ids.any? && org_ids.exclude?(@options[:current_user].organisation.id)
    else
      edition.organisation_association_enabled? &&
        edition.edition_organisations.map(&:organisation_id).exclude?(@options[:current_user].organisation.id)
    end
  end
end
