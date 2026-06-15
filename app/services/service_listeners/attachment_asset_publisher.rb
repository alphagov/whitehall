module ServiceListeners
  class AttachmentAssetPublisher
    def self.call(attachable)
      Attachment.includes(:attachment_data).where(attachable: attachable.attachables).find_each do |attachment|
        next unless attachment.attachment_data

        PublishAttachmentAssetJob.perform_async(attachment.attachment_data.id)
      end


      Image.includes(:attachment_data).where(edition: attachable).find_each do |image|
        next unless image.image_data

        PublishAttachmentAssetJob.perform_async(image.image_data.id, ImageData)
      end
    end
  end
end
