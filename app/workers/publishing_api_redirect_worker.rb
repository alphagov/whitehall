class PublishingApiRedirectWorker < PublishingApiWorker
  def call(base_path, redirects, locale, options = {})
    draft = options.fetch("draft", false)
    redirect = PublishingApiPresenters::Redirect.new(base_path, redirects)
    draft ? save_draft(redirect) : send_item(redirect, locale)
  end
end
