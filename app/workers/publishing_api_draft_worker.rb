class PublishingApiDraftWorker < PublishingApiWorker
  def send_item(payload, locale = nil)
    send_item_to_draft_stack(payload)
  end
end
