module ServiceListeners
  class AttachmentDraftStatusUpdater
    attr_reader :attachment

    def initialize(attachment)
      @attachment = attachment
    end

    def update!
      return unless attachment.file?
      attachment_data = attachment.attachment_data
      draft = !visibility_for(attachment_data).visible?
      enqueue_job(attachment_data.file, draft)
      if attachment_data.pdf?
        enqueue_job(attachment_data.file.thumbnail, draft)
      end
    end

  private

    def visibility_for(attachment_data)
      AttachmentVisibility.new(attachment_data, _anonymous_user = nil)
    end

    def enqueue_job(uploader, draft)
      legacy_url_path = uploader.asset_manager_path
      AssetManagerUpdateAssetWorker.perform_async(legacy_url_path, draft: draft)
    end
  end
end
