excluded_states = %w[superseded deleted unpublished]

cr_ids = ConsultationResponse
  .joins(:consultation)
  .where.not(editions: { state: excluded_states })
  .pluck(:id)

cfer_ids = CallForEvidenceResponse
  .joins(:call_for_evidence)
  .where.not(editions: { state: excluded_states })
  .pluck(:id)

response_attachment_data_ids = Attachment
  .where(attachable_type: "ConsultationResponse", attachable_id: cr_ids)
  .or(Attachment.where(attachable_type: "CallForEvidenceResponse", attachable_id: cfer_ids))
  .where.not(deleted: true)
  .distinct
  .pluck(:attachment_data_id)

pg_attachment_data_ids = Attachment
  .where(attachable_type: "PolicyGroup")
  .where.not(deleted: true)
  .distinct
  .pluck(:attachment_data_id)

attachment_data_ids = (response_attachment_data_ids + pg_attachment_data_ids).uniq
puts "Enqueueing #{attachment_data_ids.count} attachment data records"

attachment_data_ids.each do |id|
  AssetManagerAttachmentMetadataJob.perform_async(id)
end

puts "Done"
