begin
  asset_manager_id = "608ab5fde90e076aaf0a32ac"
  AssetManager::AssetDeleter.call(asset_manager_id)
rescue AssetManager::ServiceHelper::AssetNotFound
  logger.info("Asset #{asset_manager_id} has already been deleted from Asset Manager")
end
