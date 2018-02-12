module ServiceListeners
  class AttachmentDraftStatusUpdater
    attr_reader :edition

    def initialize(edition)
      @edition = edition
    end

    def update!
      if edition.allows_attachments?
        edition.attachments.select(&:file?).each do |attachment|
          attachment_data = attachment.attachment_data
          legacy_url_path = attachment_data.file.asset_manager_path
          draft = !AttachmentVisibility.new(attachment_data, nil).visible?
          AssetManagerUpdateAssetWorker.perform_async(legacy_url_path, draft)
          attachment_data.file.versions.each_value do |uploader|
            legacy_url_path = uploader.asset_manager_path
            AssetManagerUpdateAssetWorker.perform_async(legacy_url_path, draft)
          end
        end
      end
    end
  end
end
