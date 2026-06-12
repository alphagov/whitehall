class EditionAuthBypassAssetPropagator
  attr_reader :edition

  def initialize(edition)
    @edition = edition
  end

  def propagate
    update_file_attachments
    update_image_attachments
    update_consultation_attachments
    update_call_for_evidence_attachments
  end

private

  def new_attributes
    { "auth_bypass_ids" => [edition.auth_bypass_id].compact }
  end

  def update_file_attachments
    return unless edition.respond_to?(:attachments) && edition.attachments.files.present?

    edition.attachments.files.each do |file_attachment|
      attachment_data_id = file_attachment.attachment_data.id
      AssetManagerUpdateAssetJob.perform_async_in_queue("asset_manager_updater", "AttachmentData", attachment_data_id, new_attributes)
    end
  end

  def update_image_attachments
    edition.images.each do |image|
      image_data_id = image.image_data.id
      AssetManagerUpdateAssetJob.perform_async_in_queue("asset_manager_updater", "ImageData", image_data_id, new_attributes)
    end
  end

  def update_consultation_attachments
    return unless edition.is_a?(Consultation)

    if edition.consultation_participation&.consultation_response_form.present?
      response_form = edition.consultation_participation.consultation_response_form
      response_form_data_id = response_form.consultation_response_form_data.id

      AssetManagerUpdateAssetJob.perform_async_in_queue("asset_manager_updater", "ConsultationResponseFormData", response_form_data_id, new_attributes)
    end

    if edition.outcome.present?
      edition.outcome.attachments.files.each do |file_attachment|
        attachment_data_id = file_attachment.attachment_data.id
        AssetManagerUpdateAssetJob.perform_async_in_queue("asset_manager_updater", "AttachmentData", attachment_data_id, new_attributes)
      end
    end

    if edition.public_feedback.present?
      edition.public_feedback.attachments.files.each do |file_attachment|
        attachment_data_id = file_attachment.attachment_data.id
        AssetManagerUpdateAssetJob.perform_async_in_queue("asset_manager_updater", "AttachmentData", attachment_data_id, new_attributes)
      end
    end
  end

  def update_call_for_evidence_attachments
    return unless edition.is_a?(CallForEvidence)

    if edition.call_for_evidence_participation&.call_for_evidence_response_form.present?
      response_form = edition.call_for_evidence_participation.call_for_evidence_response_form
      response_form_data_id = response_form.call_for_evidence_response_form_data.id

      AssetManagerUpdateAssetJob.perform_async_in_queue("asset_manager_updater", "CallForEvidenceResponseFormData", response_form_data_id, new_attributes)
    end

    if edition.outcome.present?
      edition.outcome.attachments.files.each do |file_attachment|
        attachment_data_id = file_attachment.attachment_data.id
        AssetManagerUpdateAssetJob.perform_async_in_queue("asset_manager_updater", "AttachmentData", attachment_data_id, new_attributes)
      end
    end
  end
end
