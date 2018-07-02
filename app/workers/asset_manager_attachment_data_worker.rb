class AssetManagerAttachmentDataWorker < WorkerBase
  sidekiq_options queue: 'asset_manager', unique: :until_and_while_executing

  def perform(attachment_data_id)
    attachment_data = AttachmentData.find(attachment_data_id)
    return unless attachment_data.uploaded_to_asset_manager_at

    [
      AssetManagerAttachmentDraftStatusUpdateWorker,
      AssetManagerAttachmentLinkHeaderUpdateWorker,
      AssetManagerAttachmentAccessLimitedWorker,
      AssetManagerAttachmentDeleteWorker,
    ].each do |worker|
      worker.new.perform(attachment_data_id)
    end

    AttachmentData.where(replaced_by: attachment_data).find_each do |replaced_attachment_data|
      AssetManagerAttachmentReplacementIdUpdateWorker.new.perform(replaced_attachment_data.id)
    end
  end
end
