class AssetManager::AttachmentReplacementIdUpdater
  def self.call(attachment_data)
    AssetManager::AttachmentUpdater.call(attachment_data, replacement_id: true)
  end
end
