all_attachment_datas_on_deleted_attachments = AttachmentData.joins(
  :attachments
).where(attachments: { deleted: true })

#AttachmentData objects can be shared across multiple attachments
#So we only delete those that aren't related to any undeleted attachments
attachment_datas_to_delete = all_attachment_datas_on_deleted_attachments.reject do |attachment_data|
  Attachment.not_deleted.where(attachment_data_id: attachment_data.id).exists?
end

attachment_datas_to_delete.each(&:destroy)
