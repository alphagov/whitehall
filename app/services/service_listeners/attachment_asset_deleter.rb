module ServiceListeners
  class AttachmentAssetDeleter
    def self.call(attachable)
      Attachment.includes(:attachment_data).where(attachable: attachable.attachables).find_each do |attachment|
        attachment_data = attachment.attachment_data

        next unless attachment_data&.deleted?

        DeleteAttachmentAssetJob.perform_async(attachment_data.id)
      end
    end
  end
end
