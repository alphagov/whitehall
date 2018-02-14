Whitehall.attachment_notifier.tap do |notifier|
  notifier.subscribe do |_event, attachment|
    if attachment.attachable.is_a?(PolicyGroup)
      ServiceListeners::AttachmentDraftStatusUpdater
        .new(attachment)
        .update!
    end
  end
end
