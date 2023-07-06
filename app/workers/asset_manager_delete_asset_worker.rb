class AssetManagerDeleteAssetWorker < WorkerBase
  sidekiq_options queue: "asset_manager"

  def perform(legacy_url_path, asset_manager_id)
    AssetManager::AssetDeleter.call(legacy_url_path, asset_manager_id)
  end
end
