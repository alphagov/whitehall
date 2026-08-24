module ServiceListeners
  class AttachmentAssetPublisher
    def self.call(attachable)
      Attachment.includes(:attachment_data).where(attachable: attachable.attachables).find_each do |attachment|
        next unless attachment.attachment_data

        PublishAttachmentAssetJob.perform_async(attachment.attachment_data.id)
      end

      if attachable.is_a?(Edition)
        Image.includes(:image_data).unscoped.where(edition: attachable.attachables).find_each do |image|
          PublishAttachmentAssetJob.perform_async(image.image_data.id, "ImageData")
        end
      end
    end
  end
end
