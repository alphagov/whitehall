class AssetManagerAttachmentRedirectUrlUpdateWorker < WorkerBase
  sidekiq_options queue: "asset_manager"

  def perform(attachment_data_id)
    attachment_data = AttachmentData.find_by(id: attachment_data_id)
    return if attachment_data.blank?

    AssetManager::AttachmentUpdater.redirect(attachment_data)
  end
end
