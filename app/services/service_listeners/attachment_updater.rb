module ServiceListeners
  class AttachmentUpdater
    extend LockedDocumentConcern
    def self.update_all_attachment_data_for(attachable)
      if attachable.is_a?(Edition)
        check_if_locked_document(edition: attachable)
      end

      Attachment.where(attachable: attachable.attachables).find_each do |attachment|
        next unless attachment.attachment_data

        update_attachment_data(attachment.attachment_data)
      end
    end

    def self.update_attachment_data(attachment_data)
      AssetManagerAttachmentMetadataWorker.perform_async(attachment_data.id)
    end
  end
end
