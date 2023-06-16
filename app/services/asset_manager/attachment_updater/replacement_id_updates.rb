class AssetManager::AttachmentUpdater::ReplacementIdUpdates
  def self.call(attachment_data)
    return [] unless attachment_data.replaced?

    replacement = attachment_data.replaced_by

    if attachment_data.assets.empty?
      Enumerator.new do |enum|
        enum.yield(
          AssetManager::AttachmentUpdater::Update.new(
            nil,
            attachment_data,
            attachment_data.file,
            replacement_legacy_url_path: replacement.file.asset_manager_path,
          ),
        )

        if attachment_data.pdf?
          replacement_legacy_url_path = if replacement.pdf?
                                          replacement.file.thumbnail.asset_manager_path
                                        else
                                          replacement.file.asset_manager_path
                                        end
          enum.yield(
            AssetManager::AttachmentUpdater::Update.new(
              nil,
              attachment_data,
              attachment_data.file.thumbnail,
              replacement_legacy_url_path:,
            ),
          )
        end
      end
    else
      # Both the file and its thumbnail are now represented by an Asset
      # and rely solely on the asset_manager_id rather than the legacy_url_path for updates.
      # Therefore, it is not needed to check whether or not the Attachment is a pdf.
      Enumerator.new do |enum|
        attachment_data.assets.each do |asset|
          enum.yield AssetManager::AttachmentUpdater::Update.new(
            asset.asset_manager_id, attachment_data, nil, replacement_id: replacement.id
          )
        end
      end
    end
  end
end
