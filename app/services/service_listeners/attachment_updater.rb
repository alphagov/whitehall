module ServiceListeners
  class AttachmentUpdater
    def initialize(attachable)
      @attachable = attachable
    end

    def update!
      Attachment.where(attachable: attachable.attachables).find_each do |attachment|
        next unless attachment.attachment_data

        draft_status_updater attachment.attachment_data
        redirect_url_updater attachment.attachment_data
        link_header_updater attachment.attachment_data
        access_limited_updater attachment.attachment_data
        deleter attachment.attachment_data

        AttachmentData.where(replaced_by_id: attachment.attachment_data.id).find_each do |attachment_data|
          replacement_id_updater attachment_data
        end
      end
    end

  private

    attr_reader :attachable

    def draft_status_updater(attachment_data)
      ServiceListeners::AttachmentDraftStatusUpdater
        .new(attachment_data)
        .update!
    end

    def redirect_url_updater(attachment_data)
      ServiceListeners::AttachmentRedirectUrlUpdater
        .new(attachment_data)
        .update!
    end

    def link_header_updater(attachment_data)
      ServiceListeners::AttachmentLinkHeaderUpdater
        .new(attachment_data)
        .update!
    end

    def access_limited_updater(attachment_data)
      ServiceListeners::AttachmentAccessLimitedUpdater
        .new(attachment_data)
        .update!
    end

    def replacement_id_updater(attachment_data)
      ServiceListeners::AttachmentReplacementIdUpdater
        .new(attachment_data)
        .update!
    end

    def deleter(attachment_data)
      ServiceListeners::AttachmentDeleter
        .new(attachment_data)
        .delete!
    end
  end
end
