class AssetManager::AttachmentUpdater::RedirectUrlUpdates
  def self.call(attachment_data)
    redirect_url = nil
    if attachment_data.unpublished? && attachment_data.present_at_unpublish?
      redirect_url = attachment_data.unpublished_edition.unpublishing.document_url
    end

    if attachment_data.assets.empty?
      Enumerator.new do |enum|
        enum.yield AssetManager::AttachmentUpdater::Update.new(
          nil, attachment_data, attachment_data.file, redirect_url:
        )

        if attachment_data.pdf?
          enum.yield AssetManager::AttachmentUpdater::Update.new(
            nil, attachment_data, attachment_data.file.thumbnail, redirect_url:
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
            asset.asset_manager_id, attachment_data, nil, redirect_url:
          )
        end
      end
    end
  end
end
