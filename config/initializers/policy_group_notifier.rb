Whitehall.policy_group_notifier.tap do |notifier|
  notifier.subscribe do |_event, policy_group|
    ServiceListeners::AttachmentDraftStatusUpdater
      .new(policy_group)
      .update!
  end
end
