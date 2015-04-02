class PublishingApiDraftWorker < PublishingApiWorker
  def send_item(base_path, content)
    Whitehall.publishing_api_client.put_draft_content_item(base_path, content)
  end
end
