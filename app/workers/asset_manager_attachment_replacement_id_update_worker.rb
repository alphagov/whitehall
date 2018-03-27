class AssetManagerAttachmentReplacementIdUpdateWorker < WorkerBase
  def perform(attachment_data_id)
    attachment_data = AttachmentData.find_by(id: attachment_data_id)
    return unless attachment_data.present?
    return unless attachment_data.replaced?
    replacement = attachment_data.replaced_by

    replace_path(attachment_data, attachment_data.file.asset_manager_path, replacement.file.asset_manager_path)
    if attachment_data.pdf?
      if replacement.pdf?
        replace_path(attachment_data, attachment_data.file.thumbnail.asset_manager_path, replacement.file.thumbnail.asset_manager_path)
      else
        replace_path(attachment_data, attachment_data.file.thumbnail.asset_manager_path, replacement.file.asset_manager_path)
      end
    end
  end

  def replace_path(attachment_data, legacy_url_path, replacement_legacy_url_path)
    AssetManagerUpdateAssetWorker.new.perform(attachment_data, legacy_url_path, 'replacement_legacy_url_path' => replacement_legacy_url_path)
  end
end
