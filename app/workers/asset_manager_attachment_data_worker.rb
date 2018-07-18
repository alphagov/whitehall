class AssetManagerAttachmentDataWorker < WorkerBase
  sidekiq_options queue: 'asset_manager'

  def perform(attachment_data_id)
    attachment_data = AttachmentData.find(attachment_data_id)
    return unless attachment_data.present? && attachment_data.uploaded_to_asset_manager_at

    [
      AssetManager::AttachmentAccessLimitedUpdater,
      AssetManager::AttachmentDeleter,
      AssetManager::AttachmentDraftStatusUpdater,
    ].each do |task|
      task.call(attachment_data)
    end

    [
      AssetManagerAttachmentLinkHeaderUpdateWorker,
    ].each do |worker|
      worker.new.perform(attachment_data_id)
    end

    AttachmentData.where(replaced_by: attachment_data).find_each do |replaced_attachment_data|
      AssetManagerAttachmentReplacementIdUpdateWorker.new.perform(replaced_attachment_data.id)
    end
  end
end
