class AssetManagerAttachmentDraftStatusUpdateWorker < WorkerBase
  def perform(attachment_data)
    draft = attachment_data.draft?
    enqueue_job(attachment_data.file, draft)
    if attachment_data.pdf?
      enqueue_job(attachment_data.file.thumbnail, draft)
    end
  end

private

  def enqueue_job(uploader, draft)
    legacy_url_path = uploader.asset_manager_path
    AssetManagerUpdateAssetWorker.perform_async(legacy_url_path, draft: draft)
  end
end
