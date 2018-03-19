class AssetManagerAttachmentMetadataUpdateWorker < WorkerBase
  def perform(attachment_data_id)
    [
      AssetManagerAttachmentAccessLimitedWorker,
      AssetManagerAttachmentDeleteWorker,
      AssetManagerAttachmentDraftStatusUpdateWorker,
      AssetManagerAttachmentLinkHeaderUpdateWorker,
      AssetManagerAttachmentRedirectUrlUpdateWorker,
      AssetManagerAttachmentReplacementIdUpdateWorker
    ].each do |worker|
      worker.set(queue: 'asset_migration').perform_async(attachment_data_id)
    end
  end
end
