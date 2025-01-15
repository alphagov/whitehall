class AssetManagerAttachmentMetadataWorker < WorkerBase
  sidekiq_options queue: "asset_manager"

  def perform(attachment_data_id)
    attachment_data = AttachmentData.find(attachment_data_id)

    return if attachment_data.blank?

    # This call needs to be here to run when we do an edition discard.
    # See next commit where we remove this call in favour of a custom discard service listener.
    AssetManager::AttachmentDeleter.call(attachment_data)

    return unless attachment_data.all_asset_variants_uploaded?

    AssetManager::AttachmentUpdater.call(attachment_data)

    AttachmentData.where(replaced_by: attachment_data).find_each do |replaced_attachment_data|
      AssetManager::AttachmentUpdater.replace(replaced_attachment_data)
    rescue AssetManager::ServiceHelper::AssetNotFound => e
      logger.warn("AssetManagerAttachmentMetadataWorker: #{e}")
    end
  end
end
