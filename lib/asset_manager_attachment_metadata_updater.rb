class AssetManagerAttachmentMetadataUpdater
  def self.update_range(start, finish)
    AttachmentData.find_each(start: start, finish: finish) do |attachment_data|
      next unless File.exist?(attachment_data.file.path)

      [
       AssetManagerAttachmentAccessLimitedWorker,
       AssetManagerAttachmentDeleteWorker,
       AssetManagerAttachmentDraftStatusUpdateWorker,
       AssetManagerAttachmentLinkHeaderUpdateWorker,
       AssetManagerAttachmentRedirectUrlUpdateWorker,
       AssetManagerAttachmentReplacementIdUpdateWorker
      ].each do |worker|
        worker.set(queue: 'asset_migration').perform_async(attachment_data.id)
      end
    end
  end
end
