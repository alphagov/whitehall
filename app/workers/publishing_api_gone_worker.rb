class PublishingApiGoneWorker < PublishingApiWorker
  def perform(base_path, options = {})
    draft = options.fetch("draft", false)
    gone_item = PublishingApiPresenters::Gone.new(base_path)
    draft ? save_draft(gone_item) : send_item(gone_item, 'en')
  end
end
