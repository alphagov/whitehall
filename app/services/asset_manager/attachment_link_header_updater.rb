class AssetManager::AttachmentLinkHeaderUpdater < WorkerBase
  def self.call(attachment_data)
    visible_edition = attachment_data.visible_edition_for(nil)
    return unless visible_edition.present?

    parent_document_url = Whitehall.url_maker.public_document_url(visible_edition)

    self.update_asset(attachment_data, attachment_data.file, parent_document_url)
    self.update_asset(attachment_data, attachment_data.file.thumbnail, parent_document_url) if attachment_data.pdf?
  end

  def self.update_asset(attachment_data, uploader, parent_document_url)
    AssetManager::AssetUpdater.call(
      attachment_data,
      uploader.asset_manager_path,
      "parent_document_url" => parent_document_url,
    )
  end
end
