module ServiceListeners
  class AttachmentAssetPublisher
    def self.call(attachable)
      Attachment.includes(:attachment_data).where(attachable: attachable.attachables).find_each do |attachment|
        next unless attachment.attachment_data

        PublishAttachmentAssetJob.perform_async(attachment.attachment_data.id)
      end

      if attachable.is_a?(Edition)
        attachable.images.respond_to?(:unscoped) && attachable.images.unscoped.find_each do |image|
          PublishAttachmentAssetJob.perform_async(image.image_data.id, "ImageData")
        end

        if attachable.response_form_data.present?
          PublishAttachmentAssetJob.perform_async(attachable.response_form_data.id, attachable.response_form_data.class.name)
        end
      end
    end
  end
end
