class AssetManagerAttachmentMetadataJob < JobBase
  sidekiq_options queue: "asset_manager"

  def perform(assetable_id, assetable_type = "AttachmentData")
    klass = assetable_type.constantize
    asset_data = klass.find(assetable_id)

    return if asset_data.blank?
    return unless asset_data.all_asset_variants_uploaded?

    AssetManager::AttachmentUpdater.call(asset_data)

    # Only replace assets whose model actually supports asset replacement (e.g. AttachmentData, ImageData).
    return unless klass.include?(Replaceable)

    klass.where(replaced_by: asset_data).find_each do |replaced_attachment_data|
      AssetManager::AttachmentUpdater.replace(replaced_attachment_data)
    rescue AssetManager::ServiceHelper::AssetNotFound => e
      logger.warn("AssetManagerAttachmentMetadataJob: #{e}")
    end
  end
end
