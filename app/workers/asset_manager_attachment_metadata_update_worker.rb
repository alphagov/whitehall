class AssetManagerAttachmentMetadataUpdateWorker < WorkerBase
  sidekiq_options queue: 'asset_migration'

  def perform(attachment_data_id)
    [
      AssetManagerAttachmentAccessLimitedWorker,
      AssetManagerAttachmentDeleteWorker,
      AssetManagerAttachmentDraftStatusUpdateWorker,
      AssetManagerAttachmentLinkHeaderUpdateWorker,
      AssetManagerAttachmentRedirectUrlUpdateWorker,
      AssetManagerAttachmentReplacementIdUpdateWorker
    ].each do |worker|
      worker.new.perform(attachment_data_id)
    end
  end
end
