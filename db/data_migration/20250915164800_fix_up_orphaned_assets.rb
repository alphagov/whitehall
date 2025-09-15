orphaned_assets_for_deletion = %w[
  5bdc102ce5274a6e0e61f420
  5bdc10f2ed915d150754eb67
  5bdc1115e5274a6e0bc6cfdc
  5c9a0858ed915d07a97369f8
  5c9a10cee5274a3ca310bb2f
]

orphaned_assets_for_deletion.each do |asset_manager_id|
  AssetManager::AssetDeleter.call(asset_manager_id)
rescue AssetManager::ServiceHelper::AssetNotFound
  logger.info("Asset #{asset_manager_id} has already been deleted from Asset Manager")
end
