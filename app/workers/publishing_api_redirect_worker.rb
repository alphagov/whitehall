class PublishingApiRedirectWorker < PublishingApiWorker
  def perform(base_path, redirects)
    redirect = Whitehall::PublishingApi::Redirect.new(base_path, redirects)
    send_item(base_path, redirect.as_json)
  end
end
