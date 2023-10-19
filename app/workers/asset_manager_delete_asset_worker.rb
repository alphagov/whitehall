class AssetManagerDeleteAssetWorker < WorkerBase
  sidekiq_options queue: "asset_manager"

  def perform(legacy_url_path, asset_manager_id)
    begin
      AssetManager::AssetDeleter.call(legacy_url_path, asset_manager_id)
    rescue AssetManager::ServiceHelper::AssetNotFound
      logger.info("Asset #{asset_manager_id} has already been deleted from Asset Manager")
    end
    Asset.where(asset_manager_id:).delete_all
  end
end
