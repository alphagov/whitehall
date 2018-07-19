class AssetManager::AttachmentReplacementIdUpdater
  def self.call(attachment_data)
    return unless attachment_data.replaced?

    replacement = attachment_data.replaced_by

    self.replace_path(attachment_data, attachment_data.file, replacement.file)
    if attachment_data.pdf?
      if replacement.pdf?
        self.replace_path(attachment_data, attachment_data.file.thumbnail, replacement.file.thumbnail)
      else
        self.replace_path(attachment_data, attachment_data.file.thumbnail, replacement.file)
      end
    end
  end

  def self.replace_path(attachment_data, original_file, replacement_file)
    AssetManager::AssetUpdater.call(
      attachment_data,
      original_file.asset_manager_path,
      "replacement_legacy_url_path" => replacement_file.asset_manager_path,
    )
  rescue AssetManager::ServiceHelper::AssetNotFound
    raise AssetNotFound.new('Asset unavailable, it may not have synced yet')
  end

  class AssetNotFound < StandardError; end
end
