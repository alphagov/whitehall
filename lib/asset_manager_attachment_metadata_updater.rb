class AssetManagerAttachmentMetadataUpdater
  def self.update_range(start, finish)
    AttachmentData.find_each(start: start, finish: finish) do |attachment_data|
      [
       AssetManagerAttachmentAccessLimitedWorker,
       AssetManagerAttachmentDeleteWorker,
       AssetManagerAttachmentDraftStatusUpdateWorker,
       AssetManagerAttachmentLinkHeaderUpdateWorker,
       AssetManagerAttachmentRedirectUrlUpdateWorker,
       AssetManagerAttachmentReplacementIdUpdateWorker
      ].each do |worker|
        worker.perform_async(attachment_data.id)
      end
    end
  end
end
