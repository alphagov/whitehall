class AssetManager::AttachmentDeleter
  def self.call(attachment_data)
    return unless attachment_data.deleted?

    attachment_data.assets.each do |asset|
      AssetManager::AssetDeleter.call(nil, asset.asset_manager_id)
    end
  end
end
