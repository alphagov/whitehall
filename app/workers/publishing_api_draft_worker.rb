class PublishingApiDraftWorker < PublishingApiWorker
  def send_item(payload, locale = nil)
    save_draft(payload)
  end
end
