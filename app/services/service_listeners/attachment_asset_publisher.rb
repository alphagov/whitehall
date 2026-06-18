module ServiceListeners
  class AttachmentAssetPublisher
    def self.call(attachable)
      Attachment.includes(:attachment_data).where(attachable: attachable.attachables).find_each do |attachment|
        next unless attachment.attachment_data

        PublishAttachmentAssetJob.perform_async(attachment.attachment_data.id)
      end

      if attachable.is_a?(Edition)

        attachable.images.each do |image|
          PublishAttachmentAssetJob.perform_async(image.image_data.id, "ImageData")
        end

        if attachable.respond_to?(:call_for_evidence_participation) && attachable&.call_for_evidence_participation&.call_for_evidence_response_form&.call_for_evidence_response_form_data
          PublishAttachmentAssetJob.perform_async(attachable.call_for_evidence_participation.call_for_evidence_response_form.call_for_evidence_response_form_data.id, "CallForEvidenceResponseFormData")
        end

        if attachable.respond_to?(:consultation_participation) && attachable&.consultation_participation&.consultation_response_form&.consultation_response_form_data
          PublishAttachmentAssetJob.perform_async(attachable&.consultation_participation&.consultation_response_form&.consultation_response_form_data.id, "ConsultationResponseFormData")
        end        
      end    
    end
  end
end
