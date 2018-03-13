class AssetManagerAttachmentLinkHeaderUpdateWorker < WorkerBase
  def perform(attachment_data_id)
    attachment_data = AttachmentData.find_by(id: attachment_data_id)
    return unless attachment_data.present?
    visible_edition = attachment_data.visible_edition_for(nil)
    return unless visible_edition.present?

    parent_document_url = Whitehall.url_maker.public_document_url(visible_edition)

    enqueue_job(attachment_data.file, parent_document_url)
    if attachment_data.pdf?
      enqueue_job(attachment_data.file.thumbnail, parent_document_url)
    end
  end

private

  def enqueue_job(uploader, parent_document_url)
    legacy_url_path = uploader.asset_manager_path
    AssetManagerUpdateAssetWorker.perform_async(legacy_url_path, parent_document_url: parent_document_url)
  end
end
