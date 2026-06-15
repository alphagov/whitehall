class AssetManagerAttachmentMetadataJob < JobBase
  sidekiq_options queue: "asset_manager"

  def perform(attachment_data_id, assetable_type = "AttachmentData")
    assetable_type_model = assetable_type.constantize

    attachment_data = assetable_type.constantize.where(id: attachment_data_id).first

    return if attachment_data.blank?

    return unless attachment_data.all_asset_variants_uploaded?

    AssetManager::AttachmentUpdater.call(attachment_data)

    if assetable_type == AttachmentData
      AttachmentData.where(replaced_by: attachment_data).find_each do |replaced_attachment_data|
        AssetManager::AttachmentUpdater.replace(replaced_attachment_data)
      rescue AssetManager::ServiceHelper::AssetNotFound => e
        logger.warn("AssetManagerAttachmentMetadataJob: #{e}")
      end
    end
  end
end
