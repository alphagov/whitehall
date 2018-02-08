Whitehall.consultation_response_notifier.tap do |notifier|
  notifier.subscribe do |_event, response|
    ServiceListeners::AttachmentDraftStatusUpdater
      .new(response)
      .update!
  end
end
