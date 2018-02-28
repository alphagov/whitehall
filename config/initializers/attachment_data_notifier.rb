Whitehall.attachment_data_notifier.tap do |notifier|
  notifier.subscribe('replace') do |_event, attachment_data|
    ServiceListeners::AttachmentReplacementIdUpdater
      .new(attachment_data)
      .update!
  end
end
