class DeleteAttachmentAssetJob < WorkerBase
  sidekiq_options queue: "asset_manager"

  def perform(attachment_data_id)
    attachment_data = AttachmentData.find(attachment_data_id)

    attachment_data.assets.each do |asset|
      AssetManager::AssetDeleter.call(asset.asset_manager_id)
    rescue AssetManager::ServiceHelper::AssetNotFound
      logger.info("Asset #{asset.asset_manager_id} has already been deleted from Asset Manager")
    end
  end
end
