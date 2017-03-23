class PublishingApiWithdrawalWorker < PublishingApiWorker
  def perform(content_id, explanation, locale, allow_draft = false)
    unpublished_at = Edition
      .joins(:document)
      .where(documents: {content_id: content_id})
      .where(state: "withdrawn")
      .pluck(:updated_at)
      .first

    Services.publishing_api.unpublish(
      content_id,
      type: "withdrawal",
      locale: locale,
      explanation: Whitehall::GovspeakRenderer.new.govspeak_to_html(explanation),
      allow_draft: allow_draft,
      unpublished_at: unpublished_at
    )
  rescue GdsApi::HTTPNotFound, GdsApi::HTTPUnprocessableEntity
    # nothing to do here as we can't unpublish something that doesn't exist
    nil
  end
end
