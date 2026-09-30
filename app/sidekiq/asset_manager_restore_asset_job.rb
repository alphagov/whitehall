class AssetManagerRestoreAssetJob < JobBase
  sidekiq_options queue: "asset_manager_updater"

  def perform(asset_manager_id, redirect_url)
    AssetManager::AssetRestorer.call(asset_manager_id, redirect_url)
  end
end
