class PublishingApiRedirectWorker < PublishingApiWorker
  def perform(base_path, redirects, edition_content_id)
    redirect = Whitehall::PublishingApi::Redirect.new(base_path, redirects, edition_content_id)
    send_item(base_path, redirect.as_json)
  end
end
