Whitehall.attachment_notifier.tap do |notifier|
  notifier.subscribe do |_event, attachment|
    ServiceListeners::AttachmentDraftStatusUpdater
      .new(attachment)
      .update!
  end
end
