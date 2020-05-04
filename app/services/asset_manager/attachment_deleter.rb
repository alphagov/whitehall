class AssetManager::AttachmentDeleter
  def self.call(attachment_data)
    return unless attachment_data.deleted?

    delete_asset_for(attachment_data.file)
    delete_asset_for(attachment_data.file.thumbnail) if attachment_data.pdf?
  end

  def self.delete_asset_for(uploader)
    AssetManager::AssetDeleter.call(uploader.asset_manager_path)
  end
end
