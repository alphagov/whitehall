class AssetManagerUpdateWhitehallAssetWorker < WorkerBase
  sidekiq_options queue: "asset_manager_updater"

  def perform(klass, id, attributes)
    model = klass.constantize.find(id)
    asset_data = GlobalID::Locator.locate(model.to_global_id)
    path = asset_data.file.asset_manager_path
    AssetManager::AssetUpdater.call(asset_data, path, attributes)
    logger.info "[AssetManagerUpdateWhitehallAssetWorker]  govuk_request_id: #{GdsApi::GovukHeaders.headers[:govuk_request_id]} asset_manager_path: #{path}"

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
