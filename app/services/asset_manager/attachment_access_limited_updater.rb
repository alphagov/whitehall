class AssetManager::AttachmentAccessLimitedUpdater
  def self.call(attachment_data)
    AssetManager::AttachmentUpdater.call(attachment_data, access_limited: true)
  end
end
