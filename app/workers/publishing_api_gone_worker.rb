class PublishingApiGoneWorker < PublishingApiWorker
  def perform(content_id, alternative_path, explanation, locale)
    Whitehall.publishing_api_v2_client.unpublish(
      content_id,
      alternative_path: alternative_path,
      explanation: explanation,
      type: "gone",
      locale: locale,
    )
  end
end
