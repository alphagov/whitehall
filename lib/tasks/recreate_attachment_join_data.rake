task recreate_attachment_join_data: :environment do
  require Rails.root.join('lib/recreate_attachment_join_data')
  RecreateAttachmentJoinData.new.execute(SupportingPageAttachmentOld, SupportingPageAttachment, :supporting_page_id)
  RecreateAttachmentJoinData.new.execute(CorporateInformationPageAttachmentOld, CorporateInformationPageAttachment, :corporate_information_page_id)
  RecreateAttachmentJoinData.new.execute(ConsultationResponseAttachmentOld, ConsultationResponseAttachment, :response_id)
  RecreateAttachmentJoinData.new.execute(EditionAttachmentOld, EditionAttachment, :edition_id)
end
