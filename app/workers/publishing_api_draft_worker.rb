class PublishingApiDraftWorker < PublishingApiWorker
  def send_item(payload, _locale = nil)
    save_draft(payload)
  end
end
