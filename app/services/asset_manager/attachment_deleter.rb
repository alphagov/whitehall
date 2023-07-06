class AssetManager::AttachmentDeleter
  def self.call(attachment_data)
    return unless attachment_data.deleted?

    if attachment_data.assets.empty?
      AssetManager::AssetDeleter.call(attachment_data.file.asset_manager_path, nil)
      AssetManager::AssetDeleter.call(attachment_data.file.thumbnail.asset_manager_path, nil) if attachment_data.pdf?
    else
      attachment_data.assets.each do |asset|
        AssetManager::AssetDeleter.call(nil, asset.asset_manager_id)
      end
    end
  end
end
