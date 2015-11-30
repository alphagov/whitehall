class PublishingApiDiscardDraftWorker < PublishingApiWorker
  def perform(content_id, locale)
    Whitehall.publishing_api_v2_client.discard_draft(content_id, locale: locale)
  end
end
