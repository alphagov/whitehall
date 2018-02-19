Whitehall.attachment_notifier.tap do |notifier|
  notifier.subscribe do |_event, attachment|
    unless attachment.attachable.is_a?(Edition)
      ServiceListeners::AttachmentDraftStatusUpdater
        .new(attachment)
        .update!
    end
  end
end
