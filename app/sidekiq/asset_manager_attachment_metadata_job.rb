class AssetManagerAttachmentMetadataJob < JobBase
  sidekiq_options queue: "asset_manager"

  def perform(assetable_id, assetable_type = "AttachmentData")
    asset_data = assetable_type.constantize.find(assetable_id)

    return if asset_data.blank?

    return unless asset_data.all_asset_variants_uploaded?

    AssetManager::AttachmentUpdater.call(asset_data)

    assetable_type.constantize.where(replaced_by: asset_data).find_each do |replaced_attachment_data|
      AssetManager::AttachmentUpdater.replace(replaced_attachment_data)
    rescue AssetManager::ServiceHelper::AssetNotFound => e
      logger.warn("AssetManagerAttachmentMetadataJob: #{e}")
    end
  end
end
