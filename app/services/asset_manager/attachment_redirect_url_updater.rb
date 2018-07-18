class AssetManager::AttachmentRedirectUrlUpdater
  def self.call(attachment_data)
    AssetManager::AttachmentUpdater.call(attachment_data, redirect_url: true)
  end
end
