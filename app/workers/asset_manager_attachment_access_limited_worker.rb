class AssetManagerAttachmentAccessLimitedWorker < WorkerBase
  def perform(attachment_data_id)
    attachment_data = AttachmentData.find_by(id: attachment_data_id)
    return unless attachment_data.present?
    access_limited = []
    if attachment_data.access_limited?
      access_limited = AssetManagerAccessLimitation.for(attachment_data.access_limited_object)
    end

    enqueue_job(attachment_data.file, access_limited)
    if attachment_data.pdf?
      enqueue_job(attachment_data.file.thumbnail, access_limited)
    end
  end

private

  def enqueue_job(uploader, access_limited)
    legacy_url_path = uploader.asset_manager_path
    AssetManagerUpdateAssetWorker.perform_async(legacy_url_path, access_limited: access_limited)
  end
end
