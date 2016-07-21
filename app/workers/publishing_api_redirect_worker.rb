class PublishingApiRedirectWorker < PublishingApiWorker
  def perform(content_id, destination, locale)
    Whitehall.publishing_api_v2_client.unpublish(
      content_id,
      type: "redirect",
      locale: locale,
      alternative_path: destination,
    )
  end
end
