class AssetManagerAttachmentSetUploadedToWorker < WorkerBase
  sidekiq_options queue: "asset_manager"

  sidekiq_retries_exhausted do |msg, _|
    legacy_url_path = msg["args"][2]
    GovukError.notify AttachmentDataNotFound.new(legacy_url_path)
  end

  class AttachmentDataNotFound < StandardError
    def initialize(legacy_url_path)
      super("AttachmentData for '#{legacy_url_path}' does not exist.")
    end
  end

  # the "Transient" variant of the exception is not reported to
  # Sentry, as there is a race condition here.  Only if all retries
  # fail do we want to see the error.
  class AttachmentDataNotFoundTransient < AttachmentDataNotFound; end

  def perform(model_class, model_id, legacy_url_path)
    model = model_class.constantize.find(model_id)

    found = false
    # sadly we can't just search for url, because it's a magic
    # carrierwave thing not in our model
    Attachment.where(attachable: model.attachables).where.not(attachment_data: nil).find_each do |attachment|
      attachment_data = attachment.attachment_data
      # 'attachment.attachment_data' can still be nil even with the
      # check above, because if the 'attachment_data_id' is non-nil
      # but invalid, the 'attachment_data' will be nil - and the
      # generated SQL only checks if the 'attachment_data_id' is
      # nil.
      next unless attachment_data
      if attachment_data.url == legacy_url_path
        found = true
        attachment_data.uploaded_to_asset_manager!
      elsif attachment_data.pdf? && attachment_data.file.thumbnail.url == legacy_url_path
        # don't mark the attachment_data as uploaded when the
        # thumbnail makes it across, because we mostly care about the
        # actual pdf
        found = true
      end
    end

    # the AttachmentData should exist, so if we didn't find it try
    # again.
    raise AttachmentDataNotFoundTransient.new(legacy_url_path) unless found
  end
end
