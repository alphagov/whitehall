class AssetManagerAttachmentDraftStatusUpdateWorker < WorkerBase
  def perform(attachment_data_id)
    attachment_data = AttachmentData.find_by(id: attachment_data_id)
    return unless attachment_data.present?
    draft = attachment_data.draft? && !attachment_data.unpublished?
    enqueue_job(attachment_data.file, draft)
    if attachment_data.pdf?
      enqueue_job(attachment_data.file.thumbnail, draft)
    end
  end

private

  def enqueue_job(uploader, draft)
    legacy_url_path = uploader.asset_manager_path
    AssetManagerUpdateAssetWorker.new.perform(legacy_url_path, 'draft' => draft)
  end
end
