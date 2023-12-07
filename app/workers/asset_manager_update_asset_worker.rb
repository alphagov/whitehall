class AssetManagerUpdateAssetWorker < WorkerBase
  sidekiq_options queue: "asset_manager_updater"

  def perform(klass, id, attributes)
    model = klass.constantize.find(id)
    asset_data = GlobalID::Locator.locate(model.to_global_id)
    asset_data.assets.each do |asset|
      AssetManager::AssetUpdater.call(asset.asset_manager_id, attributes)
    end
  rescue AssetManager::ServiceHelper::AssetNotFound,
         ActiveRecord::RecordNotFound => e
    logger.error "AssetManagerUpdateAssetWorker: #{e.message}"
  end
end
