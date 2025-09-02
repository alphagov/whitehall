module ServiceListeners
  class DraftAttachmentAssetDiscarder
    def self.call(attachable)
      Attachment.includes(:attachment_data).where(attachable: attachable.attachables).find_each do |attachment|
        attachment_data = attachment.attachment_data

        DeleteAttachmentAssetJob.perform_async(attachment_data.id) if attachment_data&.needs_discarding?
      end
    end
  end
end
