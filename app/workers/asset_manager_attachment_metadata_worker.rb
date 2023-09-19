class AssetManagerAttachmentMetadataWorker < WorkerBase
  sidekiq_options queue: "asset_manager"

  def perform(attachment_data_id)
    attachment_data = AttachmentData.find(attachment_data_id)

    return if attachment_data.blank?

    AssetManager::AttachmentDeleter.call(attachment_data)

    return unless attachment_data.all_asset_variants_uploaded?

    AssetManager::AttachmentUpdater.call(
      attachment_data,
      access_limited: true,
      draft_status: true,
      link_header: true,
    )

    AttachmentData.where(replaced_by: attachment_data).find_each do |replaced_attachment_data|
      AssetManager::AttachmentUpdater.call(replaced_attachment_data, replacement_id: true)
    rescue AssetManager::ServiceHelper::AssetNotFound => e
      logger.warn("AssetManagerAttachmentMetadataWorker: #{e}")
    end
  end
end
