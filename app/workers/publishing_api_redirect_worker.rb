class PublishingApiRedirectWorker < PublishingApiWorker
  def perform(content_id, destination, locale, allow_draft = false)
    Services.publishing_api.unpublish(
      content_id,
      type: "redirect",
      locale: locale,
      alternative_path: destination.strip,
      allow_draft: allow_draft,
      discard_drafts: !allow_draft,
    )
  rescue GdsApi::HTTPNotFound
    # nothing to do here as we can't unpublish something that doesn't exist
    nil
  rescue GdsApi::HTTPUnprocessableEntity => e
    # retrying is unlikely to fix the problem, we can send the error straight to Sentry
    GovukError.notify(e)
  end
end
