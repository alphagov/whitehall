class PublishingApiWithdrawalWorker < PublishingApiWorker
  def perform(content_id, explanation, locale, allow_draft = false)
    Whitehall.publishing_api_v2_client.unpublish(
      content_id,
      type: "withdrawal",
      locale: locale,
      explanation: Whitehall::GovspeakRenderer.new.govspeak_to_html(explanation),
      allow_draft: allow_draft,
    )
  rescue GdsApi::HTTPNotFound, GdsApi::HTTPUnprocessableEntity
    # nothing to do here as we can't unpublish something that doesn't exist
    nil
  end
end
