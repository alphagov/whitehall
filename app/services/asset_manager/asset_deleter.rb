class AssetManager::AssetDeleter
  include AssetManager::ServiceHelper

  def self.call(*args)
    new.call(*args)
  end

  def call(asset_manager_id)
    attributes = find_asset_by_id(asset_manager_id)
    return if attributes["deleted"]

    asset_manager.delete_asset(asset_manager_id)
  end
end
