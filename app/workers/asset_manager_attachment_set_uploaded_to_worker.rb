class AssetManagerAttachmentSetUploadedToWorker < WorkerBase
  sidekiq_options queue: "asset_manager"

  class AttachmentDataNotFound < StandardError
    def initialize(legacy_url_path)
      super("AttachmentData for '#{legacy_url_path}' does not exist.")
    end
  end

  def perform(model_class, model_id, legacy_url_path)
    model = model_class.constantize.find(model_id)

    found = false
    # sadly we can't just search for url, because it's a magic
    # carrierwave thing not in our model
    Attachment.where(attachable: model.attachables).where.not(attachment_data: nil).find_each do |attachment|
      # 'attachment.attachment_data' can still be nil even with the
      # check above, because if the 'attachment_data_id' is non-nil
      # but invalid, the 'attachment_data' will be nil - and the
      # generated SQL only checks if the 'attachment_data_id' is
      # nil.
      if attachment.attachment_data && attachment.attachment_data.url == legacy_url_path
        found = true
        attachment.attachment_data.uploaded_to_asset_manager!
      end
    end

    # the AttachmentData should exist, so if we didn't find it try
    # again.
    raise AttachmentDataNotFound.new(legacy_url_path) unless found
  end
end
