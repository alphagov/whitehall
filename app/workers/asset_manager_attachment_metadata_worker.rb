class AssetManagerAttachmentMetadataWorker < WorkerBase
  sidekiq_options queue: "asset_manager"

  def perform(attachment_data_id)
    attachment_data = AttachmentData.find(attachment_data_id)
    return unless attachment_data.present? && attachment_data.uploaded_to_asset_manager_at

    AssetManager::AttachmentUpdater.call(
      attachment_data,
      access_limited: true,
      draft_status: true,
      link_header: true,
    )

    AssetManager::AttachmentDeleter.call(attachment_data)

    AttachmentData.where(replaced_by: attachment_data).find_each do |replaced_attachment_data|
      AssetManager::AttachmentUpdater.call(replaced_attachment_data, replacement_id: true)
    end
  end
end
