class AssetManagerAttachmentReplacementIdUpdateWorker < WorkerBase
  def perform(attachment_data_id)
    attachment_data = AttachmentData.find(attachment_data_id)
    replacement = attachment_data.replaced_by

    replace_path(attachment_data.file.asset_manager_path, replacement.file.asset_manager_path)
    if attachment_data.pdf?
      if replacement.pdf?
        replace_path(attachment_data.file.thumbnail.asset_manager_path, replacement.file.thumbnail.asset_manager_path)
      else
        replace_path(attachment_data.file.thumbnail.asset_manager_path, replacement.file.asset_manager_path)
      end
    end
  end

  def replace_path(legacy_url_path, replacement_legacy_url_path)
    worker = AssetManagerUpdateAssetWorker
    worker.perform_async(legacy_url_path, replacement_legacy_url_path: replacement_legacy_url_path)
  end
end
