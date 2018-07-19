class AssetManagerAttachmentDeleteWorker < WorkerBase
  sidekiq_options queue: 'asset_manager'

  def perform(attachment_data_id)
    attachment_data = AttachmentData.find_by(id: attachment_data_id)
    return unless attachment_data.present? && attachment_data.deleted?

    delete_asset_for(attachment_data.file)
    if attachment_data.pdf?
      delete_asset_for(attachment_data.file.thumbnail)
    end
  end

  def delete_asset_for(uploader)
    AssetManager::AssetDeleter.call(uploader.asset_manager_path)
  end
end
