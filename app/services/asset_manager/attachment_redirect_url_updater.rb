class AssetManager::AttachmentRedirectUrlUpdater
  def self.call(attachment_data)
    redirect_url = nil
    if attachment_data.unpublished?
      redirect_url = attachment_data.unpublished_edition.unpublishing.document_url
    end

    self.update_asset(attachment_data, attachment_data.file, redirect_url)
    self.update_asset(attachment_data, attachment_data.file.thumbnail, redirect_url) if attachment_data.pdf?
  end

  def self.update_asset(attachment_data, uploader, redirect_url)
    AssetManager::AssetUpdater.call(
      attachment_data, uploader.asset_manager_path, "redirect_url" => redirect_url
    )
  end
end
