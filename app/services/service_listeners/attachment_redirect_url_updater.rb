module ServiceListeners
  class AttachmentRedirectUrlUpdater
    def self.call(attachable: nil)
      Attachment.where(attachable: attachable.attachables).find_each do |attachment|
        next unless attachment.attachment_data
        AssetManagerAttachmentRedirectUrlUpdateWorker.perform_async attachment.attachment_data.id
      end
    end
  end
end
