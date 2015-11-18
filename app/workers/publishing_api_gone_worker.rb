class PublishingApiGoneWorker < PublishingApiWorker
  def perform(base_path, edition_content_id)
    gone_item = PublishingApiPresenters::Gone.new(base_path, edition_content_id)
    send_item(base_path, gone_item.as_json)
  end
end
