class AssetManager::AssetRestorer
  include AssetManager::ServiceHelper

  def self.call(*args)
    new.call(*args)
  end

  # `redirect_url` is always applied: a `nil` value clears any redirect set in Asset Manager
  def call(asset_manager_id, redirect_url)
    attributes = find_asset_by_id(asset_manager_id)

    # Asset Manager won't update a deleted live asset, so restore it first
    asset_manager.restore_asset(asset_manager_id) if attributes["deleted"]

    unless attributes["redirect_url"] == redirect_url
      asset_manager.update_asset(asset_manager_id, { "redirect_url" => redirect_url })
    end
  end
end
