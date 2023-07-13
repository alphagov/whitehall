class AssetManager::AssetDeleter
  include AssetManager::ServiceHelper

  def self.call(*args)
    new.call(*args)
  end

  def call(legacy_url_path, asset_manager_id)
    if asset_manager_id
      attributes = find_asset_by_id(asset_manager_id)
      return if attributes["deleted"]

      asset_manager.delete_asset(asset_manager_id)
    else
      attributes = find_asset_by(legacy_url_path)
      return if attributes["deleted"]

      asset_manager.delete_asset(attributes["id"])
    end
  end
end
