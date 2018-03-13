class AssetManagerAttachmentRedirectUrlUpdateWorker < WorkerBase
  def perform(attachment_data_id)
    attachment_data = AttachmentData.find(attachment_data_id)
    redirect_url = nil
    if attachment_data.unpublished?
      redirect_url = attachment_data.unpublished_edition.unpublishing.document_url
    end
    enqueue_job(attachment_data.file, redirect_url)
    if attachment_data.pdf?
      enqueue_job(attachment_data.file.thumbnail, redirect_url)
    end
  end

private

  def enqueue_job(uploader, redirect_url)
    legacy_url_path = uploader.asset_manager_path
    AssetManagerUpdateAssetWorker.new.perform(legacy_url_path, 'redirect_url' => redirect_url)
  end
end
