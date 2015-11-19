class PublishingApiRedirectWorker < PublishingApiWorker
  def perform(base_path, redirects, locale)
    redirect = Whitehall::PublishingApi::Redirect.new(base_path, redirects)
    send_item(redirect.as_json, locale)
  end
end
