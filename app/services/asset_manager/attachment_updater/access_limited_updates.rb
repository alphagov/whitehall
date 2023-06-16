class AssetManager::AttachmentUpdater::AccessLimitedUpdates
  def self.call(attachment_data)
    access_limited = []
    if attachment_data.access_limited?
      access_limited = AssetManagerAccessLimitation.for(attachment_data.access_limited_object)
    end

    if attachment_data.assets.empty?
      Enumerator.new do |enum|
        enum.yield AssetManager::AttachmentUpdater::Update.new(
          nil, attachment_data, attachment_data.file, access_limited:
        )

        if attachment_data.pdf?
          enum.yield AssetManager::AttachmentUpdater::Update.new(
            nil, attachment_data, attachment_data.file.thumbnail, access_limited:
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
            asset.asset_manager_id, attachment_data, nil, access_limited:
          )
        end
      end
    end
  end
end
