module ServiceListeners
  class AttachmentUpdater
    def self.call(attachable: nil, attachment_data: nil)
      update_attachable! attachable if attachable
      update_attachment_data! attachment_data if attachment_data
    end

    private_class_method def self.update_attachable!(attachable)
      Attachment.where(attachable: attachable.attachables).find_each do |attachment|
        next unless attachment.attachment_data
        update_attachment_data! attachment.attachment_data
      end
    end

    private_class_method def self.update_attachment_data!(attachment_data)
      return unless attachment_data.uploaded_to_asset_manager_at

      draft_status_updater attachment_data
      redirect_url_updater attachment_data
      link_header_updater attachment_data
      access_limited_updater attachment_data
      deleter attachment_data

      AttachmentData.where(replaced_by_id: attachment_data.id).find_each do |data|
        replacement_id_updater data
      end
    end

    private_class_method def self.draft_status_updater(attachment_data)
      AssetManagerAttachmentDraftStatusUpdateWorker.new.perform(attachment_data.id)
    end

    private_class_method def self.redirect_url_updater(attachment_data)
      AssetManagerAttachmentRedirectUrlUpdateWorker.new.perform(attachment_data.id)
    end

    private_class_method def self.link_header_updater(attachment_data)
      AssetManagerAttachmentLinkHeaderUpdateWorker.new.perform(attachment_data.id)
    end

    private_class_method def self.access_limited_updater(attachment_data)
      AssetManagerAttachmentAccessLimitedWorker.new.perform(attachment_data.id)
    end

    private_class_method def self.replacement_id_updater(attachment_data)
      AssetManagerAttachmentReplacementIdUpdateWorker.new.perform(attachment_data.id)
    end

    private_class_method def self.deleter(attachment_data)
      AssetManagerAttachmentDeleteWorker.new.perform(attachment_data.id)
    end
  end
end
