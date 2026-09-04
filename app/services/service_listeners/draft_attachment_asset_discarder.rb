module ServiceListeners
  class DraftAttachmentAssetDiscarder
    def self.call(attachable)
      Attachment.includes(:attachment_data).where(attachable: attachable.attachables).find_each do |attachment|
        attachment_data = attachment.attachment_data

        DeleteAttachmentAssetJob.perform_async(attachment_data.id) if attachment_data&.needs_discarding?
      end

      if attachable.is_a?(Edition)
        Image.includes(:image_data).where(edition: attachable.attachables).find_each do |image|
          image_data = image.image_data

          DeleteAttachmentAssetJob.perform_async(image_data.id, "ImageData") if image_data&.needs_discarding?
        end

        response_form_data = AttachmentAssetPublisher.response_form_data_for(attachable)
        DeleteAttachmentAssetJob.perform_async(response_form_data.id, response_form_data.class.to_s) if response_form_data&.needs_discarding?
      end
    end
  end
end
