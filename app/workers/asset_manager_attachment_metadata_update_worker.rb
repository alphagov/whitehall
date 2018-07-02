class AssetManagerAttachmentMetadataUpdateWorker < WorkerBase
  sidekiq_options queue: 'asset_migration', unique: :until_executing

  def perform(attachment_data_id)
    workers.each do |worker|
      worker.new.perform(attachment_data_id)
    end
  end

  def workers
    [
      AssetManagerAttachmentAccessLimitedWorker,
      AssetManagerAttachmentDraftStatusUpdateWorker,
      AssetManagerAttachmentLinkHeaderUpdateWorker,
      AssetManagerAttachmentRedirectUrlUpdateWorker,
      AssetManagerAttachmentReplacementIdUpdateWorker,
      AssetManagerAttachmentDeleteWorker
    ]
  end
end
