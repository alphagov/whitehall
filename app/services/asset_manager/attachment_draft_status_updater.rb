class AssetManager::AttachmentDraftStatusUpdater
  def self.call(attachment_data)
    draft = attachment_data.draft? && !attachment_data.unpublished? && !attachment_data.replaced?

    self.update_asset(attachment_data, attachment_data.file, draft)
    self.update_asset(attachment_data, attachment_data.file.thumbnail, draft) if attachment_data.pdf?
  end

  def self.update_asset(attachment_data, uploader, draft)
    AssetManager::AssetUpdater.call(
      attachment_data, uploader.asset_manager_path, "draft" => draft
    )
  end
end
