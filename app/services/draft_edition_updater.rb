class DraftEditionUpdater < EditionService
  include Rails.application.routes.url_helpers

  def perform!(skip_can_perform_check: false)
    if skip_can_perform_check || can_perform?
      update_publishing_api!
      notify!
      LinkCheckerApiService.check_links(edition, admin_link_checker_api_callback_url(host: Plek.find("whitehall-admin"))) if edition.link_check_report
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
    "update_draft"
  end
end
