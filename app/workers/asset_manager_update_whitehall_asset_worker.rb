class AssetManagerUpdateWhitehallAssetWorker < WorkerBase
  sidekiq_options queue: "asset_manager_updater"

  def perform(attachment_data_global_id, attributes)
    asset_data = GlobalID::Locator.locate(attachment_data_global_id)
    path = asset_data.file.asset_manager_path
    AssetManager::AssetUpdater.call(asset_data, path, attributes)

    # Update any other versions of the file (e.g. PDF thumbnail, or resized versions of an image)
    asset_versions = asset_data.file.versions.values.select(&:present?)
    asset_versions.each do |version|
      AssetManager::AssetUpdater.call(asset_data, version.asset_manager_path, attributes)
    end
  rescue AssetManager::ServiceHelper::AssetNotFound,
         AssetManager::AssetUpdater::AssetAlreadyDeleted,
         ActiveRecord::RecordNotFound => e
    logger.error "AssetManagerUpdateWhitehallAssetWorker: #{e.message}"
  end
end
