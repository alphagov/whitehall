class PublishingApiComingSoonWorker < WorkerBase

  def perform(base_path, publish_timestamp, locale)
    coming_soon = PublishingApiPresenters::ComingSoon.new(base_path, publish_timestamp, locale)

    Whitehall.publishing_api_client.put_content_item(base_path, coming_soon.as_json)
  end
end
