class AssetManagerAttachmentDraftStatusUpdateWorker < WorkerBase
  sidekiq_options queue: 'asset_manager'

  def perform(attachment_data_id)
    attachment_data = AttachmentData.find_by(id: attachment_data_id)
    return unless attachment_data.present?
    draft = attachment_data.draft? && !attachment_data.unpublished? && !attachment_data.replaced?
    enqueue_job(attachment_data, attachment_data.file, draft)
    if attachment_data.pdf?
      enqueue_job(attachment_data, attachment_data.file.thumbnail, draft)
    end
  end

private

  def enqueue_job(attachment_data, uploader, draft)
    legacy_url_path = uploader.asset_manager_path
    AssetManagerUpdateAssetWorker.new.perform(attachment_data, legacy_url_path, 'draft' => draft)
  end
end
