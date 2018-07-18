class AssetManager::AttachmentDraftStatusUpdater
  def self.call(attachment_data)
    AssetManager::AttachmentUpdater.call(attachment_data, draft_status: true)
  end
end
