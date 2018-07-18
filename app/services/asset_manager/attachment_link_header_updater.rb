class AssetManager::AttachmentLinkHeaderUpdater < WorkerBase
  def self.call(attachment_data)
    AssetManager::AttachmentUpdater.call(attachment_data, link_header: true)
  end
end
