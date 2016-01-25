class PublishingApiRedirectWorker < PublishingApiWorker
  def perform(base_path, redirects, locale)
    redirect = PublishingApiPresenters::Redirect.new(base_path, redirects)
    send_item(redirect, locale)
  end
end
