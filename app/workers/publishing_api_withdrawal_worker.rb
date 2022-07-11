class PublishingApiWithdrawalWorker < PublishingApiWorker
  # `explanation` and `unpublished_at` come from the unpublishing object. Rather than
  # performing a database query here to look up the `unpublishing` linked to the most
  # recent edition, we pass it in directly because the `unpublishing` isn't always
  # saved in the database yet when this worker runs.
  def perform(content_id, explanation, locale, allow_draft, unpublished_at)
    check_if_locked_document(content_id: content_id)

    Services.publishing_api.unpublish(
      content_id,
      type: "withdrawal",
      locale: locale,
      explanation: Whitehall::GovspeakRenderer.new.govspeak_to_html(explanation),
      allow_draft: allow_draft,
      unpublished_at: Time.zone.parse(unpublished_at.to_s),
    )
  rescue GdsApi::HTTPNotFound, GdsApi::HTTPUnprocessableEntity
    # nothing to do here as we can't unpublish something that doesn't exist
    nil
  end
end
