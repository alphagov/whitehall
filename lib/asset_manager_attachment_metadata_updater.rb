class AssetManagerAttachmentMetadataUpdater
  def self.update_range(start, finish)
    AttachmentData.find_each(start: start, finish: finish) do |attachment_data|
      next unless File.exist?(attachment_data.file.path)

      AssetManagerAttachmentMetadataUpdateWorker.perform_async(attachment_data.id)
    end
  end
end
