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

        response_form_data = response_form_data_for(attachable)
        if response_form_data
          PublishAttachmentAssetJob.perform_async(response_form_data.id, response_form_data.class.to_s)
        end
      end
    end

    def self.response_form_data_for(edition)
      case edition
      when Consultation
        edition.consultation_participation&.consultation_response_form&.consultation_response_form_data
      when CallForEvidence
        edition.call_for_evidence_participation&.call_for_evidence_response_form&.call_for_evidence_response_form_data
      end
    end
  end
end
