module ServiceListeners
  class AttachmentAssetPublisher
    def self.call(attachable)
      Attachment.includes(:attachment_data).where(attachable: attachable.attachables).find_each do |attachment|
        next unless attachment.attachment_data

        PublishAttachmentAssetJob.perform_async(attachment.attachment_data.id)
      end
    end
  end
end
