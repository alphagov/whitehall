image_count = 0

Image
  .joins(:edition)
  .where(editions: { state: Edition::PRE_PUBLICATION_STATES })
  .where.not(editions: { auth_bypass_id: nil })
  .find_each do |image|
    AssetManagerUpdateAssetJob.perform_async_in_queue(
      "bulk_republishing",
      "ImageData",
      image.image_data_id,
      { "auth_bypass_ids" => [image.edition.auth_bypass_id] },
    )
    image_count += 1
  end

cfe_count = 0

CallForEvidence
  .where(state: Edition::PRE_PUBLICATION_STATES)
  .where.not(auth_bypass_id: nil)
  .find_each do |edition|
    new_attributes = { "auth_bypass_ids" => [edition.auth_bypass_id] }

    response_form = edition.call_for_evidence_participation&.call_for_evidence_response_form
    if response_form&.call_for_evidence_response_form_data.present?
      AssetManagerUpdateAssetJob.perform_async_in_queue(
        "bulk_republishing",
        "CallForEvidenceResponseFormData",
        response_form.call_for_evidence_response_form_data.id,
        new_attributes,
      )
      cfe_count += 1
    end

    next if edition.outcome.blank?

    edition.outcome.attachments.files.each do |file_attachment|
      AssetManagerUpdateAssetJob.perform_async_in_queue(
        "bulk_republishing",
        "AttachmentData",
        file_attachment.attachment_data.id,
        new_attributes,
      )
      cfe_count += 1
    end
  end

puts "Enqueued auth bypass propagation for #{image_count} image assets and #{cfe_count} call for evidence assets"
