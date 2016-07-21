class PublishingApiWithdrawalWorker < PublishingApiWorker
  def perform(content_id, explanation, locale)
    Whitehall.publishing_api_v2_client.unpublish(
      content_id,
      type: "withdrawal",
      locale: locale,
      explanation: explanation
    )
  end
end
