class AssetManagerAttachmentReplacementIdUpdateWorker < WorkerBase
  def perform(attachment_data_id)
    attachment_data = AttachmentData.find(attachment_data_id)
    replacement = attachment_data.replaced_by

    legacy_url_path = attachment_data.file.asset_manager_path
    replacement_legacy_url_path = replacement.file.asset_manager_path
    worker = AssetManagerUpdateAssetWorker
    worker.perform_async(legacy_url_path, replacement_legacy_url_path: replacement_legacy_url_path)
    if attachment_data.pdf?
      if replacement.pdf?
        legacy_url_path = attachment_data.file.thumbnail.asset_manager_path
        replacement_legacy_url_path = replacement.file.thumbnail.asset_manager_path
        worker.perform_async(legacy_url_path, replacement_legacy_url_path: replacement_legacy_url_path)
      else
        legacy_url_path = attachment_data.file.thumbnail.asset_manager_path
        replacement_legacy_url_path = replacement.file.asset_manager_path
        worker.perform_async(legacy_url_path, replacement_legacy_url_path: replacement_legacy_url_path)
      end
    end
  end
end
